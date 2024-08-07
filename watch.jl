#!/usr/bin/env julia
using FileWatching
include("build.jl")

function watch(path=get(ARGS, 1, "notes/"))
	while true
		@info "Watching for changes" path
		FileWatching.watch_folder(path)
		FileWatching.unwatch_folder(path)
		build()
	end
end

watch()
