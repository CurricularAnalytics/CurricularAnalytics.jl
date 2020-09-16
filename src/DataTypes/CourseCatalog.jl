##############################################################
# Course Catalog data type
# Stores the collection of courses available at an institution
mutable struct CourseCatalog
    id::Int                             # Unique course catalog ID
    name::AbstractString                # Name of the course catalog
    institution::AbstractString         # Institution offering the courses in the catalog 
    date_range::Tuple                   # range of dates the catalog is applicable over
    catalog::Dict{Int, Course}          # dictionary of courses in (course_id, course) format

    # Constructor
    function CourseCatalog(name::AbstractString, institution::AbstractString; courses::Array{Course}=Array{Course,1}(), 
                   catalog::Dict{Int,Course}=Dict{Int,Course}(), date_range::Tuple=(), id::Int=0)
        this = new()
        this.name = name
        this.institution = institution
        this.catalog = catalog
        this.date_range = date_range
        this.id = mod(hash(this.name * this.institution), UInt32)
        length(courses) > 0 ? add_course!(this, courses) : nothing
        return this
    end
end

# add a course to a course catalog, if the course is already in the catalog, it is not added again
function add_course!(cc::CourseCatalog, course::Course)
    !is_duplicate(cc, course) ? cc.catalog[course.id] = course : nothing
end

function add_course!(cc::CourseCatalog, courses::Array{Course,1})
    for course in courses
        add_course!(cc, course)
    end
end

function is_duplicate(cc::CourseCatalog, course::Course)
    course.id in keys(cc.catalog) ? true : false
end 

# Return a course in a course catalog
function course(cc::CourseCatalog, prefix::AbstractString, num::AbstractString, name::AbstractString)
    hash_val = mod(hash(name * prefix * num * cc.institution), UInt32)
    if hash_val in keys(cc.catalog)
        return cc.catalog[hash_val]
    else
        error("Course: $prefix $num: $name at $institution does not exist in catalog: $(cc.name)")
    end
end