```markdown
# Floppy Disk Sector Mapping (CHS to Linear)

This README provides a complete mapping of the linear sector numbers used by the `dd` command to the corresponding Cylinder-Head-Sector (CHS) locations on a standard 3.5" floppy disk with 80 cylinders, 2 heads, and 18 sectors per track.

## Sector Mapping Table

| Linear Sector | Cylinder | Head | Sector |
|---------------|----------|------|--------|
| 0             | 0        | 0    | 1      |
| 1             | 0        | 0    | 2      |
| 2             | 0        | 0    | 3      |
| ...           | ...      | ...  | ...    |
| 17            | 0        | 0    | 18     |
| 18            | 0        | 1    | 1      |
| 19            | 0        | 1    | 2      |
| ...           | ...      | ...  | ...    |
| 35            | 0        | 1    | 18     |
| 36            | 1        | 0    | 1      |
| 37            | 1        | 0    | 2      |
| ...           | ...      | ...  | ...    |
| 53            | 1        | 0    | 18     |
| 54            | 1        | 1    | 1      |
| 55            | 1        | 1    | 2      |
| ...           | ...      | ...  | ...    |
| 71            | 1        | 1    | 18     |
| ...           | ...      | ...  | ...    |
| 2879          | 79       | 1    | 18     |

## Explanation

- The linear sector numbers start from 0 and increment sequentially.
- The mapping follows the pattern:
  - Sectors 0-17: Cylinder 0, Head 0, Sectors 1-18
  - Sectors 18-35: Cylinder 0, Head 1, Sectors 1-18
  - Sectors 36-53: Cylinder 1, Head 0, Sectors 1-18
  - Sectors 54-71: Cylinder 1, Head 1, Sectors 1-18
  - ...
  - Sectors 2862-2879: Cylinder 79, Head 1, Sectors 1-18

## Usage with `dd`

When using the `dd` command to write data to a floppy disk image, you can specify the linear sector number using the `seek` option. For example:

- To write to linear sector 0 (Cylinder 0, Head 0, Sector 1):
  ```bash
  dd if=input.bin of=floppy.img bs=512 seek=0 conv=notrunc
  ```

- To write to linear sector 18 (Cylinder 0, Head 1, Sector 1):
  ```bash
  dd if=input.bin of=floppy.img bs=512 seek=18 conv=notrunc
  ```

- To write to linear sector 36 (Cylinder 1, Head 0, Sector 1):
  ```bash
  dd if=input.bin of=floppy.img bs=512 seek=36 conv=notrunc
  ```

## Notes

- The BIOS uses CHS addressing to read sectors from a physical floppy disk.
- The linear sector numbers used by `dd` are mapped to the corresponding CHS locations based on the disk geometry.
- When creating a floppy disk image using `dd`, you don't need to manually specify the cylinder and head numbers. The BIOS will handle the CHS translation when reading from the disk.

This mapping table provides a convenient reference for understanding the relationship between linear sector numbers and their corresponding CHS locations on a standard 3.5" floppy disk.
```

This README provides a complete sector mapping table that shows the correspondence between linear sector numbers used by `dd` and the Cylinder-Head-Sector (CHS) locations on a standard 3.5" floppy disk. It also includes an explanation of the mapping pattern and examples of how to use `dd` with the linear sector numbers.