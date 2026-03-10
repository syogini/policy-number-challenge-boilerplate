# PolicyScanner

PolicyScanner is a small Ruby library (under the `PolicyOcr` module) that performs parsing of policy numbers written using a 7‑segment–style ASCII format. It:

- **Scans** an input text file in 4‑line blocks (3 lines of ASCII digits + 1 blank separator)
- **Converts** each 3×3 digit block into a 9‑digit policy number
- **Validates** each policy number using a checksum rule
- **Writes** the results into a timestamped output file in the same directory as the input

---

## Input format

The input file (for example `spec/fixtures/sample.txt`) is expected to contain:

- **3 lines** per policy number, each exactly **27 characters** long  
  - Each digit is represented in a 3×3 grid (3 columns per digit × 9 digits = 27 chars)
  - Characters are restricted to: space `' '`, underscore `'_'`, and pipe `'|'`
- **1 separator line** (usually blank) after each 3‑line group

Example (simplified) for `000000000`:

```text
 _  _  _  _  _  _  _  _  _ 
| || || || || || || || || |
|_||_||_||_||_||_||_||_||_|
```

---

## How it works

- **Module / classes**
  - `PolicyOcr::PolicyScanner` (in `lib/policy_ocr.rb`)
    - Reads the input file line‑by‑line
    - Groups lines into 3‑line blocks (`@line_list`)
    - Uses `PolicyNumberGenerator` to convert each block into a 9‑digit string
    - Validates each number with `validate_policy_number?`
    - Writes results to `output_YYYYMMDDHHMMSS.txt` in the input file’s directory
  - `PolicyOcr::PolicyNumberGenerator` (in `lib/policy_number_generator.rb`)
    - Encodes each character of the three input lines into numeric codes:
      - `' '` → `0`, `'|'` → `1`, `'_'` → `2`
    - For each digit (3×3 block), matches the pattern to produce `0`–`9`
    - If a pattern does not match any known digit, it emits `'?'` for that position
- **Validation / status flags**
  - If a policy number contains `**?`**, it is considered **illegible** and marked `ILL`
  - Otherwise the number is validated using a checksum:
    - For a 9‑digit string d1 \dots d9, compute \sum d_i \times (10 - i)
    - If the sum mod 11 is `0`, the number is valid
  - The output line is:
    ```text
    <policy_number><space><status>
    ```
    where `<status>` is `""`, `"ILL"`, or `"ERR"`.

---

## Usage

### From the command line

The easiest way to run PolicyScanner is via the provided script:

```bash
ruby bin/scan_policies.rb ../spec/fixtures/sample.txt
```

If you omit the argument, it defaults to `../spec/fixtures/sample.txt`:

```bash
ruby bin/scan_policies.rb
```

This will create a timestamped `output_*.txt` file in the **same directory as the input file**.

### As a library

```ruby
require_relative "lib/policy_ocr"

input_path = File.expand_path("spec/fixtures/sample.txt", __dir__)
scanner = PolicyOcr::PolicyScanner.for(input_path)

# Runs the full pipeline: scan + generate policy numbers + write output file
scanner.process
```

After running `process`, you should see a new file in the same directory as the input, e.g.:

```text
spec/fixtures/output_20260309094743.txt
```

Each line in the output file contains the scanned policy number and its validation status.

### Direct validation helper

You can also call the checksum validator directly:

```ruby
scanner = PolicyOcr::PolicyScanner.for(input_path)
scanner.validate_policy_number?("123456789")  # => true/false
```

---

## Development & tests

This project uses RSpec. To run the tests:

```bash
bundle install
bundle exec rspec
```

The specs in `spec/policy_ocr_spec.rb` cover:

- Loading the module and fixture file
- Grouping lines into 3‑line blocks (`scan`)
- Generating policy numbers from known patterns (`PolicyNumberGenerator`)
- Handling unknown/invalid digit patterns with `?`
- Writing validated numbers and marking `ILL`/`ERR` correctly

