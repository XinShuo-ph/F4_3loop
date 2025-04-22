import re
import os
import time
import sys

def process_file(input_file, output_file, marker=None):
    print(f"Processing {input_file} to {output_file}")
    start_time = time.time()
    
    # Read the input file
    with open(input_file, 'r') as f:
        content = f.read()
    
    # Count original equations
    original_equations = content.count('\n') + 1
    print(f"Found {original_equations} lines in input file")
    
    # Identify markers if not specified
    if marker is None:
        # Find all variable markers (like cc, ccc) in the content
        all_markers = re.findall(r'([a-zA-Z]+)\[\d+,\s*\d+\]', content)
        unique_markers = list(set(all_markers))
        print(f"Detected variable markers: {unique_markers}")
    else:
        unique_markers = [marker]
        print(f"Using specified marker: {marker}")
    
    # Process each marker
    for marker in unique_markers:
        print(f"Processing marker: {marker}")
        
        # Handle expressions with negative numbers like (-3*cc23t3)/2
        neg_fraction_pattern = rf'\(\-(\d+)\*({marker}\[\d+,\s*\d+\])\)/(\d+)'
        content = re.sub(neg_fraction_pattern, r'-\1/\3*\2', content)

        # Pattern to match (numerator*marker[x,y])/denominator
        fraction_pattern = rf'\((\d+)\*({marker}\[\d+,\s*\d+\])\)/(\d+)'
        # First pass: Replace with numerator/denominator*marker[x,y]
        content = re.sub(fraction_pattern, r'\1/\3*\2', content)
        
        # Pattern to convert marker[x,y] to markerxty
        bracket_pattern = rf'{marker}\[(\d+),\s*(\d+)\]'
        # Second pass: Replace marker[x,y] with markerxty
        content = re.sub(bracket_pattern, rf'{marker}\1t\2', content)
    # After all markers are processed, handle terms like cc218t4/4
    for marker in unique_markers:
        marker_with_t = rf'{marker}\d+t\d+'
        standalone_fraction_pattern = rf'({marker_with_t})/(\d+)'
        content = re.sub(standalone_fraction_pattern, r'1/\2*\1', content)
    
    # Write the processed content to the output file
    with open(output_file, 'w') as f:
        f.write(content)
    
    end_time = time.time()
    print(f"Processing completed in {end_time - start_time:.2f} seconds")
    print(f"Output written to {output_file}")


if __name__ == "__main__":
    # Get command line arguments
    if len(sys.argv) >= 3:
        dir_input = sys.argv[1]
        dir_output = sys.argv[2]
        marker = sys.argv[3] if len(sys.argv) >= 4 else None
    else:
        # Default paths
        dir_input = "/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/goff/parse-equations-master/integrability_w3_eqs_expand.txt"
        dir_output = "/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/goff/parse-equations-master/integrability_w3_eqs_expand_parsed.txt"
        marker = None

    if os.path.exists(dir_input):
        process_file(dir_input, dir_output, marker)
    else:
        print(f"Warning: {dir_input} not found")