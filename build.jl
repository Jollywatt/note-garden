if !isdefined(Main, :Revise)
	const includet = include
end

includet("templates.jl")


function mkcd(f, path)
	mkpath(path)
	cd(f, path)
end

trimnotesuffix(filename) = replace(filename, ".note."=>".")

function clean()
	rm("build", recursive=true, force=true)
end


function multinote(byext::Dict{Symbol,String})

	combos = Dict(
		Set([:typ, :pdf]) => (file=:pdf, src=:typ),
		Set([:jl, :html]) => (file=:html, src=:jl),
		Set([:jl]) => (file=:jl, src=nothing),
	)

	if keys(byext) in keys(combos)
		roles = combos[keys(byext)]
		byrole = map(roles) do ext
			get(byext, ext, nothing)
		end
		(kind=roles.file, byrole...)
	else
		@error "Can't recognise multi-file note" byext
	end

end


function inbuilddir(srcfile)
	dest = replace(basename(srcfile), ".note."=>".")
	run(`ln $srcfile build/$dest`)
	dest
end


function findnotes()
	filesbyname = Dict{String,Dict{Symbol,String}}()

	for (root, dirs, files) in walkdir("notes/")
		filter!(!startswith("."), files)
		for file in files

			m = match(r"^(.*)\.note\.(\w+)$", file)
			isnothing(m) && continue
			name, ext = m
			path = joinpath(root, file)

			if name ∉ keys(filesbyname)
				filesbyname[name] = Dict()
			end
			filesbyname[name][Symbol(ext)] = path
		end
	end

	sort(Dict(name => multinote(files) for (name, files) in sort(filesbyname)))
end


function rendernote(::Val{:pdf}, name, note)
	inbuilddir(note.src)
	pdf = inbuilddir(note.file)
	open("build/$name.html", "w") do f
		html = Templates.pdf(
			title=name,
			file=pdf,
		)
		write(f, html)
	end
end

function rendernote(::Val{:jl}, name, note)
	file = inbuilddir(note.file)
	open("build/$name.html", "w") do f
		html = Templates.julia(
			title=name,
			code=read(joinpath("build", file), String),
		)
		write(f, html)
	end
end

function rendernote(::Val{:html}, name, note)
	inbuilddir(note.file)
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

	for (name, note) in notes
		@info "Rendering note" name
		rendernote(Val(note.kind), name, note)
	end

	cd("build") do
		open("index.html", "w") do f
			write(f, Templates.toc(notes))
		end
	end

	nothing
end
