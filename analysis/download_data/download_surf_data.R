suppressMessages(library(tidyverse))
suppressMessages(library(here))
library(glue)
suppressMessages(library(sf))
library(rajudas)
library(jsonlite)
suppressMessages(library(lubridate))
suppressMessages(library(devtools))
suppressMessages(library(rondas))
setwd("~/projects/personal/r/2023/rondas/")
devtools::load_all()

# setwd("~/projects/personal/r/2023/rondas/")
# devtools::load_all()
# devtools::install(quick = T)


# for the log -------------------------------------------------------------
t = Sys.time() %>% str_sub(1,19)
print(glue("Run at: {t}"))


# dirs for the data -------------------------------------------------
base_dir = "~/projects/personal/r/2023/rondas"

dirs =
  list(
    raw_data = here(base_dir, "data_downloaded/surfdata/per_day"),
    preprocessed_data = here(base_dir, "data_preprocessed")
    # per_spot_raw = here(base_dir, "data_downloaded/surfdata/per_spot")
  )

walk(dirs, function(d) {
  if (!dir.exists(d)) {
    dir.create(d, recursive = T)
  }
})


# get the cells -----------------------------------------------------------
cells = rondas::get_cells(4*4*4)

# safe version of queriying data ------------------------------------------
safe_fromJSON = purrr::safely(fromJSON)

# get raw data ----------------------------------------------------------------
regions_data = vector("list", length=length(cells))

suppressWarnings({
  for (i in seq_along(cells)) {
    print(i)
    # cell
    cell = cells[[i]]

    #url
    url = glue(
      "https://services.surfline.com/kbyg/mapview?south={cell$south}&west={cell$west}&north={cell$north}&east={cell$east}"
    )

    # raw data
    raw_data = safe_fromJSON(url)

    if (!is.null(raw_data$error)) {
      next
    }

    raw_data = raw_data$result



    # formt raw mapview data
    formatted_data = rondas::format_raw_mapview_data(raw_data)

    # regions data
    regions_data[[i]] = formatted_data


  }
})

# filter out nas
regions_data = regions_data[!is.na(regions_data)]


# bind together to make on big chunky df
all = bind_rows(regions_data) %>%
  select(-where(is.list))
rm(regions_data)

# create path for the raw data
time = Sys.time()
timezone = Sys.timezone()
time_id = format(time, "%Y_%m_%d_%H")

op = glue("{dirs$raw_data}/{time_id}.Rds")
if(file.exists(op)){
  unlink(op)
}

if(!dir.exists(dirname(op))){
  dir.create(dirname(op), recursive = T)
}

saveRDS(all, op)

# make clean data --------------------------------------------------------
make_clean_data(dirs)


# commit to github --------------------------------------------------------
git_cmd = glue("cd {base_dir} && git add -A && git commit -m 'new Data {t}' && git push")
system(git_cmd)


print(
glue(
"
Done!

"))













