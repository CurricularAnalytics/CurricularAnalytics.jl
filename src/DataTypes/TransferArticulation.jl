
# Transfer articulation map for a home (recieving xfer) institution 
mutable struct TransferArticulation
    name::AbstractString                # Name of the transfer articulation data structure
    institution::AbstractString         # Institution receiving the transfer courses (home institution)
    date_range::Tuple                   # Range of dates over which the transfer articulation data is applicable 
    transfer_catalogs::Dict{Int,CourseCatalog}  # Dictionary of transfer institution catalogs, in (CourseCatalog id, catalog) format 
    home_catalog::CourseCatalog         # Course catalog of recieving institution
    transfer_map::Dict{Tuple{Int,Int},Array{Int}}  # Dictionary in ((xfer_catalog_id, xfer_course_id), array of home_course_ids) format

    # Constructor
    function TransferArticulation(name::AbstractString, institution::AbstractString, home_catalog::CourseCatalog, 
              transfer_catalogs::Dict{Int,CourseCatalog}=Dict{Int,CourseCatalog}(), 
              transfer_map::Dict{Tuple{Int,Int},Array{Int}}=Dict{Tuple{Int,Int},Array{Int}}(), date_range::Tuple=())
        this = new()
        this.name = name
        this.institution = institution
        this.transfer_catalogs = transfer_catalogs
        this.home_catalog = home_catalog
        this.transfer_map = transfer_map
        return this
    end
end

function add_transfer_catalog(ta::TransferArticulation, transfer_catalog::CourseCatalog)
    ta.transfer_catalogs[transfer_catalog.id] = transfer_catalog
end

# A single transfer course may articulate to more than one course at the home institution
# TODO: add the ability for a transfer course to partially satifsfy a home institution course (i.e., some, but not all, course credits)
function add_transfer_course(ta::TransferArticulation, home_course_ids::Array{Int}, transfer_catalog_id::Int, transfer_course_id::Int)
    ta.transfer_map[(transfer_catalog_id, transfer_course_id)] = []
    for id in home_course_ids
        push!(ta.transfer_map[(transfer_catalog_id, transfer_course_id)], id)
    end
end

# Find the course equivalency at a home institution of a course being transfered from another institution
# returns transfer equivalent course, or nothing if there is no transfer equivalency
function transfer_equiv(ta::TransferArticulation, transfer_catalog_id::Int, transfer_course_id::Int)
    haskey(ta.transfer_map, (transfer_catalog_id, transfer_course_id)) ? ta.transfer_map[(transfer_catalog_id, transfer_course_id)] : nothing
end