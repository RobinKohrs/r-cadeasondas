#' Build the cells
#'
#' @param n_quadrants
#'
#' @return
#' @export
#'
#' @examples
get_cells = function(n_quadrants = 16){

  is_power = isPower(n_quadrants)
  if(!is_power){
    stop("Must be power of 4...")
  }

  cells = build_cells(n_quadrants)
  return(cells)



}

isPower = function(y, base=4){

  # if the base is 1, the only number to satisfy that is one
  if(base == 1){
    return(y==1)
  }

  pow = 1
  while(pow < y){
   pow = pow * base
  }

  return(y == pow)
}

build_cells = function(n){


  # how many vertical sections? -----------------
  x_spacing = 360 / sqrt(n)
  y_spacing = 180 / sqrt(n)


  columns = vector("list", length = n)

  for (x in 1:sqrt(n)) {
    column = vector("list", length = sqrt(n))

    for (y in 1:sqrt(n)) {

      north = 90 - (y - 1) * y_spacing
      south = 90 - y * y_spacing


      west =  (-180) + ((x - 1) * x_spacing)
      east = -180 + x * x_spacing

      cell = list(
        north = north,
        east = east,
        south = south,
        west = west
      )

      index = ((x-1) * sqrt(n)) + y
      columns[[index]] = cell
    }
  }

  return(columns)
}


