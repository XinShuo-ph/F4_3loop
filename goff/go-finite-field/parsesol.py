import sys

def process_solution_file(input_file, output_file):
    with open(input_file, "r") as f, open(output_file, "w") as out:
        # Write the opening bracket
        out.write("{\n")
        
        # Initialize a flag to track if we've written any line
        has_written_line = False

        for line in f:
            tokens = line.strip().split()
            if not tokens:  # Skip empty lines
                continue
            
            # If we've already written a line, add the comma for the previous line
            if has_written_line:
                out.write(",\n")

            # Process the first token (variable being defined)
            result = [f"var[{tokens[0]}] -> 0 "]
            
            # Process the rest of the tokens in pairs
            for i in range(1, len(tokens), 2):
                if i + 1 < len(tokens):
                    var_idx = tokens[i]
                    coef = tokens[i + 1]
                    result.append(f"+ var[{var_idx}] * ({coef})")
            
            # Write the processed line
            out.write("".join(result) )
            
            # Set the flag indicating we've written a line
            has_written_line = True


        
        # Write the closing bracket
        out.write("}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py input_file")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = input_file + ".m"
    process_solution_file(input_file, output_file)
