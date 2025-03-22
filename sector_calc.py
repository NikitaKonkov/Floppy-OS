import argparse

def calculate_chs(sector):
    sectors_per_track = 18
    heads = 2

    # Calculate the head
    head = (sector // sectors_per_track) % heads

    # Calculate the cylinder
    cylinder = sector // (sectors_per_track * heads)

    # Calculate the sector
    sector_in_track = (sector % sectors_per_track) + 1

    return cylinder, head, sector_in_track

def main(sector_number):
    cylinder, head, sector = calculate_chs(sector_number)

    print(f"Sector {sector_number} maps to:")
    print(f"Cylinder: {cylinder}")
    print(f"Head: {head}")
    print(f"Sector: {sector}")
    if sector_number == 0:
        print("[bootloader sector]")
    elif sector_number == 1:
        print("[operating system sector]")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Calculate CHS values for a given sector number.")
    parser.add_argument("sector", type=int, help="The sector number")
    args = parser.parse_args()

    main(args.sector)