module Templates

ROOT = "/notes"

base(content; title, head="") = """
	<!DOCTYPE html>
	<html>
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<link rel="stylesheet" href="$ROOT/assets/style.css">
		$head
		<title>Joseph's notes | $title</title>
	</head>
	<body>
		$content
	</body>
	</html>
	"""

note(content; title, args...) = base("""
	<div id="header">
		<a href="$ROOT">Joseph's notes</a> ▸ $title
	</div>
	<div id="content">
		$content
	</div>
	"""; title, args...)

pdf(; title, src) = note("""
	<object data="$ROOT/$src" type="application/pdf"/>
	"""; title)

julia(; title, code) = note("""
	<div class="scroll">
		<pre><code class="language-julia">$code</code></pre>
	</div>
	"""; title, head="""
	<link rel="stylesheet" href="$ROOT/assets/highlight/styles/default.css">
	<script src="$ROOT/assets/highlight/highlight.min.js"></script>
	<script>hljs.highlightAll();</script>
	""")


toc(notes) = base("""
	Welcome to my humble Zettelkasten garden of notes.

	<ul>
	$(join("""
		<li><a href="$ROOT/$name">$name</a> ($(info.kind))</li>
	""" for (name, info) in notes))
	</ul>
	"""; title = "Home")

end # module

