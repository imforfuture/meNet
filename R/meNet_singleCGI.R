#' CpG network for a single CpG island
#' 
#' @description Builds a network of CpGs for a single CpG island (CGI). 
#' For a given CGI, all CpGs associated with the island are nodes in the network.
#' Edges are based on the correlation which is provided either directly as
#' correlation matrix of CpGs or as a data frame with CpGs in columns and 
#' variables in rows.
#' Different methods can be used to decide which edges are kept in the network:
#' "full", "clust" or "twoLyr_clust". For explanation, see details.
#' Resulting network can be weighted in which case weights are distances between
#' CpGs expressed as base pair distance.
#' 
#' @param cg_island Name of a CpG island.
#' @param link_method Method used to determine the edges of the network.
#' See details. Default value is "twoLyr_clust".
#' @param weighted Whether the resulting network will be weighted. If TRUE,
#' the weights are base pair distances between CpGs.
#' Defaults to TRUE.
#' @param cor_matrix Correlation matrix of CpG sites.
#' @param data Data frame with CpGs in columns. Variables in rows are used to
#' calculate `cor_matrix`.
#' @param cor_normalization_fun Normalization function for the correlation
#' layer. Default method is `max_normalization` function.
#' @param dist_normalization_fun Normalization function for the distance
#' layer. Default method is `neg_max_normalization` function.
#' @param cor_threshold Correlation threshold. Defaults to `0.2`.
#' @param neg_cor_threshold Negative correlation threshold. Defaults to `NULL`.
#' @param cor_stDev Threshold for the standard deviation of correlation.
#' Defaults to `NULL`.
#' @param cor_alpha Significance level of the correlation permutation test.
#' Defaults to `NULL`.
#' @param n_repetitions Number of repetitions for resampling and/or for the 
#' correlation permutation test. Defaults to `1000`.
#' @param alternative Alternative hypothesis for the correlation permutation
#' test. Default value is `"two_sided"`.
#' @param infomap_call Path to the `Infomap` on user's system.
#' Default value is `"infomap"`.
#' @param folder Folder in which the files will be saved. It is automatically
#' created if not already present. Default value is `"./meNet/"`.
#' @param file_basename Base name of the created files.
#' Default value is `"meNet_CGI_infomap"`.
#' @param relaxation_rate `multilayer-relax-rate` parameter in `Infomap` call.
#' Defaults to `0.15`.
#' @param cg_meta Data frame which defines relationship between CpG sites and 
#' CpG islands. It has CpGs in the rows and their description in the columns.
#' If CpG is part of an CGI, `cg_meta` gives the name of the island and the region
#' of an island in which the CpG is found. Additionally, if base pair distances
#' are being calculated, `cg_meta` also holds chromosomal coordinate of CpGs.
#' By default, function uses `CpG_anno450K` data frame which contains Illumina 
#' Infinium HumanMethylation450 manifest file.
#' @param cg_meta_cols Named list with `cg_meta` column names. The list must include:
#' `cg_id` naming the column with unique CpG names, `island_name` naming the column 
#' with CGI names and `island_region` naming the column with the CGI region in which
#' the CpG is located. If base pair distances are being calculated, it should
#' also include `cg_coord` naming the column with chromosomal coordinates.
#' Default value shouldn't be changed if `cg_meta` keeps it default value.
#' @param include_regions CGI regions which should be searched for CpGs besides the 
#' island itself. Can take any subset of values `"S_Shelf"`, `"S_Shore"`, 
#' `"N_Shore"`, `"N_Shelf"`. By default, only the CpGs inside the island are reported.
#' @param check_matrices Whether to check the validity of `cg_meta`, `cg_meta_cols`,
#' `cor_matrix` and `data`. `cor_matrix` and `data` are checked only if provided.
#' Defaults to `TRUE`. Change this parameter only if called within other function
#' which already preforms the check.
#' @param delete_files Should created files be automatically deleted
#' from the user's system.
#' Defaults to `FALSE`. If `save_all_files` is `TRUE` then its value is 
#' automatically changed to `FALSE.`
#' Changing the parameter to `TRUE` should be done with caution 
#' since it will allow the function to delete files from user's system.
#' 
#' @return 
#' 
#' @details 
#' For the “full” method, the full network is kept. 
#' For the other methods clustering of CpGs is performed  and only the CpGs in 
#' the same community are connected with edges.
#' For the “clust” method, Infomap clustering is used on the correlation layer 
#' while for the “twoLyr_clust”, Infomap clustering is performed on a 2-layer 
#' correlation-distance multiplex . 
#' 
#' For speed, instead of the whole correlation matrix only a submatrix with 
#' targer CpGs can be given. This may be useful if the function is called
#' multiple times in a loop.
#' 
#' Infomap \insertCite{de2015identifying}{meNet}
#' 
#' @references
#'       \insertAllCited{}
#' 
#' @importFrom Rdpack reprompt
#' @import igraph
#' 
#' @export
meNet_singleCGI <- function(cg_island, link_method="twoLyr_clust", weighted=TRUE, cor_matrix=NULL, data=NULL,
                            cor_normalization_fun=max_normalization, dist_normalization_fun=neg_max_normalization,
                            cor_threshold=0.2, neg_cor_threshold=NULL, cor_stDev=NULL, cor_alpha=NULL, n_repetitions=1000, alternative="two_sided",
                            infomap_call="infomap", folder="./meNet/", file_basename="meNet_CGI_infomap", relaxation_rate=0.15,
                            cg_meta=data("CpG_anno450K", package="meNet"), cg_meta_cols=list(cg_id="IlmnID", cg_coord="MAPINFO", island_name="UCSC_CpG_Islands_Name", island_region="Relation_to_UCSC_CpG_Island"),
                            include_regions=c(), check_matrices=TRUE, delete_files=FALSE){
  #
  if(link_method=="twoLyr_clust"){
    error_message <- 'Infomap command not working. Change the "link_method" or check installation of "Infomap" and parameter "infomap_call". For more details, see https://www.mapequation.org/infomap/.'
    tryCatch({system(paste(infomap_call,"--help"))}, error=function(e){stop(error_message)}, warning=function(w){stop(error_message)})
  }
  #
  if(!(link_method%in%c("full", "clust", "twoLyr_clust"))){
    stop('"link_method" must have one of the values "full", "clust" or "twoLyr_clust".')
  }
  #
  if(check_matrices){
    cg_meta <- .check_cgMeta_wCols(cg_meta, cg_meta_cols, necessary_cols=c("cg_id", "island_name", "island_region"), index_column="cg_id")
    if((weighted|(link_method=="twoLyr_clust"))&!("cg_coord"%in%names(cg_meta_cols))){
      stop('If distances among CpGs are used in network construction, element "cg_coord" must be provided in the named list "cg_meta_cols".')
    }
  }
  if(link_method!="full" & check_matrices){
    matrix_preprocessing <- .check_corM_dataDF(cor_matrix, data)
    cor_matrix <- matrix_preprocessing[[1]]
    data <- matrix_preprocessing[[2]]
    if(!all(rownames(cor_matrix)==colnames(cor_matrix))){
      stop(paste('"cor_matrix" row names',"don't match the column names."))
    }
  }
  # cg_list
  cg_list <- CpG_in_CGI(cg_island, cg_meta, cg_meta_cols, include_regions)
  if(length(cg_list)==0){
    warning(paste0('No CpGs found in CpG island "',cg_island ,'".'))
    return(make_empty_graph(n=0, directed=FALSE))
  }
  if(link_method!="full"){
    cg_list <- intersect(cg_list, colnames(cor_matrix))
    if(length(cg_list)==0){
      warning(paste0('Column names of "cor_matrix"/"data" don',"'t contain the CpGs found in CpG island ",'"',cg_island ,'".'))
      return(make_empty_graph(n=0, directed=FALSE))
    }
  }
  if(length(cg_list)==1){
    output_graph <- make_empty_graph(n=0, directed=FALSE)
    output_graph <- add_vertices(output_graph, length(cg_list), name=cg_list)
    return(output_graph)
  }
  # construction of the output graph
  node_df <- data.frame(IlmnID=cg_list)
  # the link method:
  if(link_method=="full"){ #fully connected graph
    edge_df <- data.frame(Node1=unlist(sapply(1:(length(cg_list)-1), function(x) cg_list[1:x])),
                          Node2=rep(cg_list[2:length(cg_list)], 1:(length(cg_list)-1)))
    if(weighted){
      distM <- as.matrix(dist(matrix(cg_meta[cg_list,cg_meta_cols$cg_coord], nrow=length(cg_list))))
      edge_df$Dist <- distM[upper.tri(distM, diag=FALSE)]
    }
    #
  }else if(link_method=="clust"){ #igraph infomap clustering
    graphCGI_cor <- meNet_cor(cor_matrix=cor_matrix, data=data, cg_ids=cg_list, cor_threshold=cor_threshold, neg_cor_threshold=neg_cor_threshold,
                              cor_stDev=cor_stDev, cor_alpha=cor_alpha, n_repetitions=n_repetitions, alternative=alternative)
    # remove negative edges
    graphCGI_cor <- delete_edges(graphCGI_cor, E(graphCGI_cor)[edge_attr(graphCGI_cor,"Cor")<0])
    if(length(E(graphCGI_cor))==0){
      graph <- make_empty_graph(n=0, directed=FALSE)
      graph <- add_vertices(graph, length(cg_list), name=cg_list)
      return(graph)
    }
    # clustering
    communities_list <- igraph::membership(igraph::cluster_infomap(graphCGI_cor, e.weights=E(graphCGI_cor)$Cor))
    cg_list_temp <- names(communities_list)
    cg_membership <- as.numeric(communities_list)
    communities <- as.numeric(names(table(cg_membership))[as.numeric(table(cg_membership))>1])
    if(length(communities)>0){
      edge_df <- dplyr::bind_rows(lapply(communities, function(x) .get_all_pairwiseCG(cg_list_temp[cg_membership==x],col1_name="Node1",col2_name="Node2")))
      if(weighted){
        distM <- as.matrix(dist(matrix(cg_meta[cg_list,cg_meta_cols$cg_coord], nrow=length(cg_list), dimnames=list(cg_list))))
        edge_df$Dist <- sapply(1:nrow(edge_df), function(x) distM[edge_df[x,1],edge_df[x,2]])
      }
    }else{
      graph <- make_empty_graph(n=0, directed=FALSE)
      graph <- add_vertices(graph, length(cg_list), name=cg_list)
      return(graph)
    }
  }else{ #2-layer infomap clustering (calls infomap on the command line)
    # cor layer
    graphCGI_cor <- meNet_cor(cor_matrix=cor_matrix, data=data, cg_ids=cg_list, cor_threshold=cor_threshold, neg_cor_threshold=neg_cor_threshold,
                              cor_stDev=cor_stDev, cor_alpha=cor_alpha, n_repetitions=n_repetitions, alternative=alternative)
    if(length(E(graphCGI_cor)[edge_attr(graphCGI_cor, "Cor")>0])==0){ #if no edges or only negative edges are left
      graph <- make_empty_graph(n=0, directed=FALSE)
      graph <- add_vertices(graph, length(cg_list), name=cg_list)
      return(graph)
    }
    # dist layer
    edgeDist_df <- data.frame(Node1=unlist(sapply(1:(length(cg_list)-1), function(x) cg_list[1:x])),
                              Node2=rep(cg_list[2:length(cg_list)], 1:(length(cg_list)-1)))
    distM <- as.matrix(dist(matrix(cg_meta[cg_list,cg_meta_cols$cg_coord], nrow=length(cg_list))))
    edgeDist_df$Dist <- distM[upper.tri(distM, diag=FALSE)]
    graphCGI_dist <- graph_from_data_frame(d=edgeDist_df, vertices=node_df, directed=FALSE)
    #
    communities_df <- meMultiplex_communities(graphCGI_cor, graphCGI_dist, physical_nodes=FALSE, layer=1, folder=folder, file_basename=file_basename,
                                              relaxation_rate=relaxation_rate, delete_files=delete_files, infomap_call=infomap_call,
                                              cor_weighted=TRUE, supp_weighted=TRUE, cor_normalization_fun=.max_normalization, supp_normalization_fun=.neg_max_normalization,
                                              inter_cor_supp=NULL, inter_supp_cor=NULL, infomap_seed=NULL)
    cg_list_temp <- communities_df[,1]
    cg_membership <- communities_df[,2]
    communities <- as.numeric(names(table(cg_membership))[as.numeric(table(cg_membership))>1])
    if(length(communities)>0){
      edge_df <- dplyr::bind_rows(lapply(communities, function(x) .get_all_pairwiseCG(cg_list_temp[cg_membership==x],col1_name="Node1",col2_name="Node2")))
      if(weighted){
        distM <- as.matrix(dist(matrix(cg_meta[cg_list,cg_meta_cols$cg_coord], nrow=length(cg_list), dimnames=list(cg_list))))
        edge_df$Dist <- sapply(1:nrow(edge_df), function(x) distM[edge_df[x,1],edge_df[x,2]])
      }
    }else{
      graph <- make_empty_graph(n=0, directed=FALSE)
      graph <- add_vertices(graph, length(cg_list), name=cg_list)
      return(graph)
    }
  }
  #
  return(graph_from_data_frame(d=edge_df, vertices=node_df, directed=FALSE))
}
