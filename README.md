# Terraform Module Generator

This Python script is a command-line tool that generates Terraform modules based on user input. It uses OpenAI's GPT model to create Terraform code, validates it, and writes it to specified files. The tool ensures that the generated Terraform module is structured correctly and provides example usage scenarios.

## Features

- **Generate Terraform Modules**: Automatically generate Terraform configuration files based on user input.
- **Validation**: Runs `terraform init` and `terraform validate` to ensure the generated code is valid.
- **Iterative Refinement**: If validation fails, the script provides feedback to the AI model to refine and improve the module.
- **Modular Output**: Outputs are split into `main.tf`, `variables.tf`, `outputs.tf`, and a `README.md` file.

## Prerequisites

- Python 3.x
- Terraform installed and accessible from the command line
- OpenAI Python client library
- OpenAI API key set as an environment variable `OPENAI_API_KEY`

## Installation

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Install the required Python packages:

   ```bash
   pip install click openai
   ```

3. Ensure that Terraform is installed and in your PATH.

## Usage

Run the script using the command line:

```bash
python generate_module.py
```

You will be prompted to provide:

- The Terraform provider you are using.
- A description of the resources you need in the module, along with any other relevant details.

The script will generate the Terraform module, validate it, and save the files to a directory named `generated_module_<timestamp>`.

## Example Output

The script generates the following files:

- `main.tf`: Contains the Terraform resources and providers.
- `variables.tf`: Contains the variable definitions.
- `outputs.tf`: Contains the output definitions.
- `README.md`: Contains details about the module, including example usage.

## Contributing

Contributions are welcome! Please submit a pull request or open an issue to discuss changes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Author

This script was developed by Chris Ball with the help of OpenAI's GPT-4o model.
