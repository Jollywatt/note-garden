function mkcd(f, path)
	mkpath(path)
	cd(f, path)
end

ROOT = "https://jollywatt.github.io/note-garden"

function template(kind)
	raw = read("templates/$kind.html", String)

end



function substitute(html; kwargs...)
	for (k, v) in kwargs
		html = replace(html, "{{$k}}"=>v)
	end
	html
end


noext(filename) = replace(filename, r"\.\w+$"=>"")

function clean()
	rm("build", recursive=true, force=true)
end

function makenote(::Val{:pdf}, name, src)
	run(`ln $src build/`)
	open("build/$name.html", "w") do f
		html = substitute(template("pdf"),
			root=ROOT,
			title=name,
			src=basename(src)
		)
		write(f, html)
	end
end

function getnotes()
	pages = Dict{String,Any}()
	for (root, dirs, files) in walkdir("notes/")
		filter!(!startswith("."), files)
		for file in files
			if endswith(file, ".pdf")
				name = noext(file)
				pages[name] = (
					kind=:pdf,
					name=name,
					file=joinpath(root, file),
				)
			end
		end
	end
	pages
end


function toc(notes)
	join(["<li><a href=\"/$k.html\">$k</a></li>" for k in keys(notes)])
end
function main()

	rm("build", recursive=true, force=true)
	mkpath("build")

	notes = getnotes()

	for (name, spec) in notes
		(; kind, name, file) = spec
		makenote(Val(kind), name, file)
	end



	cd("build") do
		open("index.html", "w") do f
			write(f, """
			Welcome to my notes garden thing.

			<ul>
			$(toc(notes))
			</ul>
			""")
		end
	end

end
