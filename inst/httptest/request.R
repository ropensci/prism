function(request) {
  gsub_request(
    request, 
    "https?\\://services\\.nacse\\.org/prism/data/get/releaseDate/us/", 
    "s/"
  )
}
