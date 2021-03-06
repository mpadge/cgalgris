% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RcppExports.R
\name{tri_xy}
\alias{tri_xy}
\title{CGAL vertex index}
\usage{
tri_xy(x, y)
}
\description{
First method uses uses a faces iterator to extract the vertex->info for
each face. A Delaunay triangulation has both finite and infinite faces
(see CGAL documentation). The infinite faces join to an external, infinite
vertex, so the finite_faces_iterator just includes the internal faces.
}
\details{
vertex index
}
