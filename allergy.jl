### A Pluto.jl notebook ###
# v0.19.42

#> [frontmatter]
#> order = "50"
#> title = "Allergy Data"

using Markdown
using InteractiveUtils

# ╔═╡ c6f49bb2-783a-11ee-0151-47703d60127f
# ╠═╡ show_logs = false
begin
    using Pkg
    Pkg.activate(Base.current_project("."))
    Pkg.instantiate()
end

# ╔═╡ f082a987-c9b6-4330-812c-f1a7aa4cfb13
begin
    using Dates
    using FunSQL
    using PlutoUI
    using DataFrames
    using HypertextLiteral
    using CSV
    using Revise
    using TRDW
end

# ╔═╡ 95a93876-78af-40a1-b55f-24062f7eddb0
TRDW.NotebookHeader("TRDW — Allergy Data")

# ╔═╡ e2b098ec-5afd-427a-a34b-cae768a35008
md"""Allergy records seem to be represented as children of one of the following high-level SNOMED concepts."""

# ╔═╡ 40083ddf-9f11-401e-a046-e2f03f94b05c
md"""Before the Epic cutover the `value_as_concept_id` was primarily used to differentate allergens."""

# ╔═╡ e837deec-3a62-4878-869b-4990754a1fdf
md"""When `value_as_concept_id` is used, the observation concept is typically `609328004|Allergic disposition`."""

# ╔═╡ 0ced86b0-2e52-4ca3-aca8-b09fd7feaa4a
md"""These SNOMED concepts can sometimes be elaborated with `value_as_concept_id` column."""

# ╔═╡ 9e0c1ceb-21b2-455a-8b0b-2458eb67abf8
md"""For historical data, many of those using this generic concept didn't map `value_as_concept_id`."""

# ╔═╡ 663f6312-f2ff-4bae-889a-15cab9a470b6
md"""For EPIC sourced data, the observation is precise but the `value_as_concept` is not provided."""

# ╔═╡ bd890e7a-5259-4548-948b-3809bd6319b0
md"""
!!! note

Our Soarian data currently fails to map categories of allergies, such as penicillins.
"""

# ╔═╡ e637cd4d-8523-41ee-a461-839e60b222fa
md"""Our EPIC sourced data has a specific exception for `"penicillins"` mapping it to `91936005|Allergy to penicillin` which works via SNOMED hierarchy to be generic."""

# ╔═╡ d858cfa7-f0a0-4616-86da-9cebb90c6d65
md"""## Appendix
"""

# ╔═╡ f171861f-fe0d-4976-861c-c28ab6e27101
begin
    DATA_WAREHOUSE = "ctsi.trdw_green" # shifted dates/times but no other PHI
    @connect DATA_WAREHOUSE
end

# ╔═╡ 67f8a286-cfc6-4f75-a87c-9d0d1ebccf84
allergy_concepts = @query concept_sets(
    alergic_disorder = [SNOMED(781474001, "Allergic disorder")],
    propensity_to_reaction = [SNOMED(420134006, "Propensity to adverse reaction")],
    hypersensitivity = [SNOMED(609406000, "Non-allergic hypersensitivity reaction")]
)

# ╔═╡ 2961fb72-cc3a-4e72-b5fb-c7f0e4086cb1
@query observation($allergy_concepts).group(ext.is_preepic).define(count())

# ╔═╡ d19520ed-7353-4c2e-a08c-5b08bd219996
@query observation($allergy_concepts).filter(isnotnull(value_as_concept_id)).group(ext.is_preepic).define(count())

# ╔═╡ fe87fb24-0c9e-456c-afc7-3e5bd5955e3e
@query observation($allergy_concepts).filter(isnotnull(value_as_concept_id)).count_concept()

# ╔═╡ 0e1f40c4-085a-4597-9fe4-a80b03204a0d
 @query begin
    observation(SNOMED(609328004, "Allergic disposition"))
    count_concept(value_as_concept_id)
end

# ╔═╡ 1ff00dca-7c61-4582-aaba-19e09c2cd46b
 @query begin
    observation($allergy_concepts)
    filter(isnull(value_as_concept_id) || value_as_concept_id == 0)
    filter(ext.is_preepic)
    count_concept(concept_id, value_as_string)
end

# ╔═╡ 5a947b47-ce4b-4a16-9d43-9095cd2f5340
 @query begin
    observation(SNOMED(609328004, "Allergic disposition"))
    filter(isnull(value_as_concept_id) || value_as_concept_id == 0)
    filter(!ext.is_preepic)
    count_concept(concept_id, value_as_string)
end

# ╔═╡ fa42532e-e4e9-4d37-9dd3-24b22506baf2
 @query begin
    observation(SNOMED(91936005, "Allergy to penicillin"))
    filter(!ext.is_preepic)
    count_concept()
end

# ╔═╡ 87f6fa05-6806-4044-b88f-ff447144ffa9
TRDW.NotebookFooter()

# ╔═╡ Cell order:
# ╟─95a93876-78af-40a1-b55f-24062f7eddb0
# ╟─e2b098ec-5afd-427a-a34b-cae768a35008
# ╠═67f8a286-cfc6-4f75-a87c-9d0d1ebccf84
# ╠═2961fb72-cc3a-4e72-b5fb-c7f0e4086cb1
# ╟─40083ddf-9f11-401e-a046-e2f03f94b05c
# ╠═d19520ed-7353-4c2e-a08c-5b08bd219996
# ╟─e837deec-3a62-4878-869b-4990754a1fdf
# ╠═fe87fb24-0c9e-456c-afc7-3e5bd5955e3e
# ╟─0ced86b0-2e52-4ca3-aca8-b09fd7feaa4a
# ╠═0e1f40c4-085a-4597-9fe4-a80b03204a0d
# ╟─9e0c1ceb-21b2-455a-8b0b-2458eb67abf8
# ╠═1ff00dca-7c61-4582-aaba-19e09c2cd46b
# ╟─663f6312-f2ff-4bae-889a-15cab9a470b6
# ╠═5a947b47-ce4b-4a16-9d43-9095cd2f5340
# ╟─bd890e7a-5259-4548-948b-3809bd6319b0
# ╟─e637cd4d-8523-41ee-a461-839e60b222fa
# ╠═fa42532e-e4e9-4d37-9dd3-24b22506baf2
# ╟─d858cfa7-f0a0-4616-86da-9cebb90c6d65
# ╠═c6f49bb2-783a-11ee-0151-47703d60127f
# ╠═f082a987-c9b6-4330-812c-f1a7aa4cfb13
# ╠═f171861f-fe0d-4976-861c-c28ab6e27101
# ╟─87f6fa05-6806-4044-b88f-ff447144ffa9
