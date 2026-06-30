import csv
import os

csv_file = "data/Pc_build_data_cleaned.csv"
output_file = "lib/data/pc_build_data_generated.dart"

with open(csv_file, 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    builds = list(reader)

with open(output_file, 'w', encoding='utf-8') as f:
    f.write("import '../models/pc_build.dart';\n\n")
    f.write("final List<PcBuild> generatedPcBuilds = [\n")
    for b in builds:
        # Escape quotes in buildNotes
        notes = b['Build_Notes'].replace("'", "\\'")
        f.write("  PcBuild(\n")
        f.write(f"    buildId: '{b['BuildID']}',\n")
        f.write(f"    cpuModel: '{b['CPU_Model']}',\n")
        f.write(f"    cpuPrice: {b['Component_Price_CPU']},\n")
        f.write(f"    motherboardModel: '{b['Motherboard_Model']}',\n")
        f.write(f"    motherboardPrice: {b['Component_Price_Motherboard']},\n")
        f.write(f"    gpuModel: '{b['GPU_Model']}',\n")
        f.write(f"    gpuPrice: {b['Component_Price_GPU']},\n")
        f.write(f"    assemblyFee: {b['Assembly_Fee']},\n")
        f.write(f"    buildNotes: '{notes}',\n")
        f.write(f"    totalPrice: {b['Total_Price']},\n")
        f.write("  ),\n")
    f.write("];\n")
