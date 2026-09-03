# revert prism path to its original state
orig_path <- getOption("prism.path.tmp")
options("prism.path.tmp" = NULL)
options("prism.path" = orig_path)
