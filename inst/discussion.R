#  sources
#   http://www.vesnam.com/Rblog/viznets3/

library(HiveR)

# ?HiveR::HEC
data(HEC)
plotHive(HEC, ch = 0.1, bkgnd = "white")

#######
#  how do we identify nodes that will need to be plotted
#    when an HPD object does not easily show this
#    or at least I don't think it does
#    with dplyr we could do the following
library(dplyr)
#  for now let's normalize with HiveR
#     hopefully, we can move this to d3/javascript side
HEC <- manipAxis( HEC, method = "norm" )
#  to get number of unique nodes by axis
HEC$nodes %>%
  group_by(axis) %>%
  # assuming same radius and size uniquely identify a node
  summarise( nrow(unique(data.frame(radius,size))) )
#  to get the unique nodes with their radius and size
nodes <- HEC$nodes %>%
  group_by(axis) %>%
  # assuming same radius and size uniquely identify a node
  do( unique( data.frame(radius = .$radius, size = .$size ) ) ) %>%
  mutate( node_id = paste0(axis,"_",1:n_distinct(radius) ) ) %>%
  ungroup %>%
  #   then we can send over a list of nodes
  #    but we will also need other meta information
  #    and we will need a mapping of node id to their new id based on unique size/radius
  #    which we should be able to accomplish by inner_join
  {suppressMessages(inner_join( .,HEC$nodes ))}

#  now that we have nodes uniquely identified
#    we'll need to add the node identifier to our links/edges
edges <- HEC$edges %>%
  {
    data.frame(
      "source" = nodes[match(.$id1,nodes$id),][["node_id"]]
      ,"target" = nodes[match(.$id2,nodes$id),][["node_id"]]
      ,.
    )
  }

#  should  be able to now pare down to only unique nodes
nodes <- nodes %>%
  group_by( node_id ) %>%
  slice(1)


# with our nodes and edges in the expected order
#   let's see if we can pass them to javascript
d3hive( data = list(nodes=nodes, edges=edges) )

#######
#   after we have identified
# try to replicate with d3_hive_links from Mike Bostock
#   https://gist.github.com/mbostock/2066415
hC_eC <- data.frame(xtabs(Freq~Hair+Eye,HairEyeColor))
nodes <- data.frame(
  x = c(
    rep(1,length(levels(hC_eC$Hair)))
    , rep(2,length(levels(hC_eC$Eye)))
  )
  , y = c(
    as.numeric(prop.table(xtabs(Freq~Hair,HairEyeColor)))
    ,as.numeric(prop.table(xtabs(Freq~Eye,HairEyeColor)))
  )
)
jsonlite::toJSON(nodes, data.frame="columns", auto_unbox=T)
# now for links need a connection between each Hair and Eye
jsonlite::toJSON(do.call(rbind,lapply(
  1:length(levels(hC_eC$Hair))
  ,function(src){
    data.frame(
      "source" = sprintf("nodes[%i]",src-1)
      ,"target" = paste0(
        "nodes["
        ,((length(levels(hC_eC$Hair))+1):(length(levels(hC_eC$Hair))+length(levels(hC_eC$Eye))))-1
        ,"]"
      )
    )
  }
)), data.frame="columns", auto_unbox=T)

library(dplyr)
data.frame(xtabs(Freq~Hair+Eye,HairEyeColor)) %>%
  group_by( Hair ) %>%
  summarize( Freq = sum(Freq) ) %>%
  ungroup %>%
  mutate( x = paste0("hair_", Hair ) ) %>%
  select( node, Freq )

# like HiveR try to get HairEyeColor data in proper form for the htmlwidget
#   we will start basic with hair importing eye
hC_eC <- data.frame(xtabs(Freq~Hair+Eye,HairEyeColor))
jsonlite::toJSON(
  c(unname(lapply(
    split(hC_eC, hC_eC$Hair)
    ,function(hair){
      list(
        "name" = paste0("hair.",as.character(hair$Hair)[1])
        ,"size" = sum(hair$Freq)
        ,"imports" = paste0("eye.",as.character(hair$Eye))
      )
    }
  )),
  unname(lapply(
    split(hC_eC, hC_eC$Eye)
    ,function(eye){
      list(
        "name" = paste0("eye.",as.character(eye$Eye)[1])
        ,"size" = sum(eye$Freq)
        ,"imports" = list()
      )
    }
  )))
  ,auto_unbox=T
)


# try to get HEC in the form expected by the d3.js hive plot gist
apply(
  HEC$nodes
  ,MARGIN = 1
  ,function(node){
    list(
      "name" = node[["lab"]]
      ,"imports" = HEC$nodes[match(
          HEC$edges[which(HEC$edges$id1==node[["id"]]),][["id2"]],HEC$nodes$id
        ),][["lab"]]
    )
  }
)
