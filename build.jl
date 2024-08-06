include("templates.jl")

function mkcd(f, path)
	mkpath(path)
	cd(f, path)
end

noext(filename) = replace(filename, r"\.\w+$"=>"")

function clean()
	rm("build", recursive=true, force=true)
end

function rendernotes()
	pages = Dict{String,Any}()
	for (root, dirs, files) in walkdir("notes/")
		filter!(!startswith("."), files)
		for file in files
			name = noext(file)
			if endswith(file, ".pdf")
				run(`ln $root/$file build/`)
				pages[name] = Templates.pdf(
					title=name,
					src=file,
				)
			elseif endswith(file, ".jl")
				run(`ln $root/$file build/`)
				pages[name] = Templates.julia(
					title=name,
					code=read(joinpath(root, file), String),
				)
			end
		end
	end
	pages
end

function build()

	rm("build", recursive=true, force=true)
	mkpath("build")

	cp("assets", "build/assets")


	notes = rendernotes()

	for (name, html) in notes
		open("build/$name.html", "w") do f
			write(f, html)
		end
	end

	cd("build") do
		open("index.html", "w") do f
			write(f, Templates.toc(notes))
		end
	end

	nothing
end
