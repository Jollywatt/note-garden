function mkcd(f, path)
	mkpath(path)
	cd(f, path)
end

ROOT = "https://jollywatt.github.io/note-garden"

function main()
	n = getnotes()

	rm("build", recursive=true, force=true)
	mkcd("build") do
		cp("../notes/", "notes")
		cd("notes") do
			for (name, files) in n
				open("$name.html", "w") do f
					write(f, """
					<h1>$name</h1>

					<div>
					<object data="$ROOT/notes/$name.pdf" type="application/pdf"/>
					</div>
					<style>
					object {
						width: 100vw;
						height: calc(100vh - 100px);
					}
					</style>
					""")
				end
			end
		end


		open("index.html", "w") do f
			write(f, """
			Welcome to my notes garden thing.

			<ul>
			$(toc(n))
			</ul>
			""")
		end
	end

end

function toc(notes)
	join(["<li><a href=\"notes/$k.html\">$k</a></li>" for k in keys(notes)])
end


function getnotes()
	files = filter(!startswith("."), readdir("notes"))
	names = map(files) do f
		replace(f, r"\.\w+$"=>"")
	end
	d = Dict{String,Vector{String}}()
	for (name, file) in zip(names, files)
		d[name] = push!(get(d, name, String[]), file)
	end
	d
end

