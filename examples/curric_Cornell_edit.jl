out = read_csv_new("examples\\template.csv")
#write_csv(out)
visualize(out, changed = function printsth(new_data) println("new_data")end , edit=true)