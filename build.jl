include("templates.jl")

function mkcd(f, path)
	mkpath(path)
	cd(f, path)
end

noext(filename) = replace(filename, r"\.\w+$"=>"")

function clean()
	rm("build", recursive=true, force=true)
end

function findnotes()
	notes = Dict{String,@NamedTuple{kind::Symbol, path::String}}()

	for (root, dirs, files) in walkdir("notes/")
		filter!(!startswith("."), files)
		for file in files
			name = noext(file)

			info = if endswith(file, ".pdf")
				(
					kind=:pdf,
					path=joinpath(root, file),
				)
			elseif endswith(file, ".html")
				(
					kind=:html,
					path=joinpath(root, file),
				)
			elseif endswith(file, ".jl")
				(
					kind=:julia,
					path=joinpath(root, file),
				)
			end

			isnothing(info) && continue

			name in keys(notes) && @error "Found duplicate name: $name" root*file notes[name]

			notes[name] = info
		end
	end
	notes
end


function rendernote(::Val{:pdf}, path, name)
	src = basename(path)
	run(`ln $path build/`)
	open("build/$name.html", "w") do file
		html = Templates.pdf(
			title=name,
			src=src,
		)
		write(file, html)
	end
end

function rendernote(::Val{:julia}, path, name)
	src = basename(path)
	run(`ln $path build/`)
	open("build/$name.html", "w") do file
		html = Templates.julia(
			title=name,
			code=read(path, String),
		)
		write(file, html)
	end
end

function rendernote(::Val{:html}, path, name)
	run(`ln $path build/$name.html`)
end

permalink(name) = "https://jollywatt.github.io/notes/"*name

function exportpermalinks(notes)
	path = joinpath(ENV["HOME"], "Documents/typst-notes/permalinks.csv")
	open(path, "w") do file
		write(file, "name,url\n")
		for (name, info) in notes
			write(file, name, ",", permalink(name), "\n")
		end
	end
end

function build()

	rm("build", recursive=true, force=true)
	mkpath("build")

	cp("assets", "build/assets")


	notes = findnotes()

	for (name, (; kind, path)) in notes
		rendernote(Val(kind), path, name)
	end

	cd("build") do
		open("index.html", "w") do f
			write(f, Templates.toc(notes))
		end
	end

	nothing
end
