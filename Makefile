default:
	@[ "${TMDB_API_TOKEN}" ] \
	&& mkdir -p MoviehubAPI/Sources/MoviehubAPI/Generated && Tools/sourcery --sources \
	Moviehub --templates Templates/AppSecrets.stencil --output MoviehubAPI/Sources/MoviehubAPI/Generated \
	--args themoviedbApiKey="${TMDB_API_TOKEN}" \
	|| ( echo "You have to set the environment variable TMDB_API_TOKEN to your token first"; exit 1 )
