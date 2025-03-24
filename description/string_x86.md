# String Instructions in x86 16-bit Mode

The x86 architecture includes a set of powerful string manipulation instructions that are particularly useful in 16-bit real mode programming. These instructions work with the SI (Source Index), DI (Destination Index), and CX (Count) registers to perform operations on strings of data.

## Complete List of String Instructions in x86 16-bit Mode

### Basic String Instructions

1. **LODSB** - Load byte from DS:SI into AL, then increment/decrement SI
   - Format: `lodsb`
   - Equivalent to: `mov al, [ds:si]` followed by `inc si` or `dec si` (depending on DF flag)

2. **LODSW** - Load word from DS:SI into AX, then increment/decrement SI by 2
   - Format: `lodsw`
   - Equivalent to: `mov ax, [ds:si]` followed by `add si, 2` or `sub si, 2`

3. **STOSB** - Store AL to ES:DI, then increment/decrement DI
   - Format: `stosb`
   - Equivalent to: `mov [es:di], al` followed by `inc di` or `dec di`

4. **STOSW** - Store AX to ES:DI, then increment/decrement DI by 2
   - Format: `stosw`
   - Equivalent to: `mov [es:di], ax` followed by `add di, 2` or `sub di, 2`

5. **MOVSB** - Move byte from DS:SI to ES:DI, then increment/decrement both SI and DI
   - Format: `movsb`
   - Equivalent to: `mov al, [ds:si]` followed by `mov [es:di], al` and then incrementing/decrementing SI and DI

6. **MOVSW** - Move word from DS:SI to ES:DI, then increment/decrement both SI and DI by 2
   - Format: `movsw`
   - Equivalent to: `mov ax, [ds:si]` followed by `mov [es:di], ax` and then incrementing/decrementing SI and DI by 2

7. **CMPSB** - Compare byte at DS:SI with byte at ES:DI, then increment/decrement SI and DI
   - Format: `cmpsb`
   - Equivalent to: `cmp [ds:si], [es:di]` followed by incrementing/decrementing SI and DI

8. **CMPSW** - Compare word at DS:SI with word at ES:DI, then increment/decrement SI and DI by 2
   - Format: `cmpsw`
   - Equivalent to: `cmp [ds:si], [es:di]` followed by incrementing/decrementing SI and DI by 2

9. **SCASB** - Compare AL with byte at ES:DI, then increment/decrement DI
   - Format: `scasb`
   - Equivalent to: `cmp al, [es:di]` followed by incrementing/decrementing DI

10. **SCASW** - Compare AX with word at ES:DI, then increment/decrement DI by 2
    - Format: `scasw`
    - Equivalent to: `cmp ax, [es:di]` followed by incrementing/decrementing DI by 2

### Direction Control

- **CLD** - Clear Direction Flag (DF=0), causing string operations to increment SI and DI
  - Format: `cld`

- **STD** - Set Direction Flag (DF=1), causing string operations to decrement SI and DI
  - Format: `std`

### REP Prefixes

These prefixes can be used with string instructions to repeat them CX times:

1. **REP** - Repeat string operation CX times (used with MOVS, STOS)
   - Format: `rep movsb`, `rep stosw`, etc.

2. **REPE/REPZ** - Repeat while equal/zero (used with CMPS, SCAS)
   - Format: `repe cmpsb`, `repz scasb`, etc.

3. **REPNE/REPNZ** - Repeat while not equal/not zero (used with CMPS, SCAS)
   - Format: `repne cmpsb`, `repnz scasb`, etc.

## Key Points to Consider

- The direction of these operations (increment or decrement) is controlled by the Direction Flag (DF).
- When DF=0 (after CLD), the index registers (SI, DI) are incremented.
- When DF=1 (after STD), the index registers are decremented.
- String operations use specific segment registers by default:
  - Source operations use DS:SI
  - Destination operations use ES:DI
- The REP prefixes use CX as a counter, decrementing it with each iteration.

## Usage Examples

```assembly
; Copy a string
cld                 ; Clear direction flag (increment mode)
mov si, source      ; Source pointer
mov di, destination ; Destination pointer
mov cx, length      ; Number of bytes to copy
rep movsb           ; Repeat MOVSB CX times

; Find a character in a string
cld                 ; Clear direction flag
mov di, string      ; String to search
mov al, 'A'         ; Character to find
mov cx, length      ; Maximum length to search
repne scasb         ; Repeat SCASB while not equal
jnz not_found       ; Jump if character not found
```

## Best Practices

1. Always set the direction flag explicitly (CLD or STD) before using string instructions.
2. Remember that REP prefixes modify CX, so save it if needed later.
3. For maximum efficiency, use the appropriate word/byte instruction based on your data.
4. When working with overlapping memory regions, be careful about the direction (CLD vs STD).
5. In 16-bit mode, remember the 64KB segment limitations when working with large strings.

These string instructions are powerful tools for efficient memory operations in 16-bit x86 assembly programming, especially in environments like bootloaders and real-mode operating systems.