using Weave

# convert_doc(joinpath("src/", "concepts-p1.jl"), joinpath("src/", "concepts-p1.jmd"))
convert_doc(joinpath("src/", "concepts-p1.jmd"), joinpath("src/", "concepts-p1.jl"))
weave(joinpath("src/", "concepts-p1.jl"), out_path = "build/")
