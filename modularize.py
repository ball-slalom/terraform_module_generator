import os
import click
import subprocess
from openai import OpenAI
from datetime import datetime

client = OpenAI()

# Set your OpenAI API key from environment variable
client.api_key = os.getenv('OPENAI_API_KEY')
if not client.api_key:
    raise EnvironmentError(
        "The environment variable OPENAI_API_KEY is not set.")


def query_model(system_prompt, prompt):
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt}
        ],
        max_tokens=16384,  # max tokens for model
        temperature=0.2
    )
    return response.model_dump()['choices'][0]['message']['content'].strip()


def run_terraform_validate(directory):
    try:
        # Run terraform init
        subprocess.run(
            ["terraform", "init"],
            cwd=directory,
            check=True,
            capture_output=True
        )

        # Run terraform validate
        subprocess.run(
            ["terraform", "validate"],
            cwd=directory,
            check=True,
            capture_output=True
        )

        return True, None
    except subprocess.CalledProcessError as e:
        # Return error output if validation fails
        return False, e.stderr.decode()


@click.command()
def generate_module():
    """
    CLI tool to generate a Terraform module based on user input.
    """

    # Prompt the user for the terraform provider they are using
    cloud_provider = click.prompt(
        "Which Terraform provider(s) are you using?"
    )

    # Prompt the user for a description of the resources
    resource_description = click.prompt(
        "Enter a description of the resources you need in the module and any other relevant details."
    )

    print("\nGenerating module...")

    default_system_prompt = (
        "You are a Terraform expert. You have extensive experience converting Terraform resources into reusable modules."
        f"You're expertise is specific to the {cloud_provider} provider."
        "You care deeply about creating modules that are easy to use and understand."
    )

    tf_system_prompt_1 = (
        default_system_prompt +
        "Your response must be in HCL format only. It will be consumed and placed directly into a .tf file."
        "Do not use markdown code fences (```) or any other formatting symbols. Provide only the plain Terraform code."
        "Include complete code for providers, resources, locals (if helpful), variables, and outputs."
        "Include helpful descriptions for every variable and output."
        "Include helpful comments with recommendations, as needed."
        "Make sure the code you provide is accurate and lines up with the latest Terraform version."
        "Be sure to include any encryption keys and roles or policies needed with the configuration."
        "Use variables to drive all resource inputs, with logical defaults."
        "If a resource type typically has child resources, include those. An example would be Aurora clusters requiring instances, etc."
        "If security groups or similar resources are part of the module, define them with validated variables and allow the user to pass in their own custom rules."
    )

    tf_system_prompt_2 = (
        default_system_prompt +
        "Your response must be in HCL format only. It will be consumed and placed directly into a .tf file."
        "Do not use markdown code fences (```) or any other formatting symbols. Provide only the plain Terraform code."
        "Include complete code for providers, resources, locals (if helpful), variables, and outputs."
        "Include helpful descriptions for every variable and output."
        "Include helpful comments with recommendations, as needed."
        "Make sure the code you provide is accurate and lines up with the latest Terraform version."
    )

    # Create a timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    # Create directory for the module
    output_dir = f"generated_module_{timestamp}"
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Create directory within the module for temp files
    temp_dir = f"{output_dir}/temp"
    if not os.path.exists(temp_dir):
        os.makedirs(temp_dir)

    complete_module_prompt = (
        f"Create a Terraform module with the following resources and any other logically related resources I might need: {resource_description}."
    )

    iteration = 0
    success = False

    while not success and iteration < 5:  # Limit iterations to prevent infinite loops
        iteration += 1

        # Generate full set of resources for module
        complete_module_content = query_model(
            tf_system_prompt_1, complete_module_prompt)

        # Write the parsed content to file
        with open(os.path.join(temp_dir, "generated_module.tf"), 'w') as file:
            file.write(complete_module_content)

        # Validate the Terraform code
        success, error_message = run_terraform_validate(temp_dir)

        if not success:
            print(
                f"Validation of iteration #{iteration} failed:\n{error_message}")
            print(f"You can review the generated module at: {temp_dir}")
            input("Press Enter to continue to the next attempt...\n")

            correction_prompt = (
                f"The following Terraform validation errors occurred: {error_message}. "
                "Please regenerate the Terraform code, correcting these errors. \n"
            )
            # Update the prompt with error feedback for regeneration
            complete_module_prompt = correction_prompt + complete_module_content

    if success:
        click.echo(
            "Terraform module validated. Writing files...")
    else:
        click.echo(
            "Failed to generate a valid Terraform module after multiple attempts.\n"
            "Writing module files that will require manual review and correction."
        )

    # Generate resources section
    resources_prompt = (
        "Pull out and return only the providers, resources, and any locals found in this module."
        f"Include the comments, but remove the variables and outputs: \n\n{complete_module_content}"
    )
    resources_content = query_model(tf_system_prompt_2, resources_prompt)

    # Generate variables section
    variables_prompt = (
        "Pull out and return only the variables found in this module."
        f"Include the comments, but remove the resources, locals, and outputs: \n\n{complete_module_content}"
    )
    variables_content = query_model(tf_system_prompt_2, variables_prompt)

    # Generate outputs section
    outputs_prompt = (
        "Pull out and return only the outputs found in this module."
        f"Include the comments, but remove the resources, locals, and variables: \n\n{complete_module_content}"
    )
    outputs_content = query_model(tf_system_prompt_2, outputs_prompt)

    # Generate readme
    readme_prompt = (
        "Given the following Terraform module code, give me a full README.md."
        "Along with detailed Terraform README content, provide 2 example uses of the module."
        "One example should use all the default values for the variables."
        "One example should use every input available."
        "Your response should not include anything other than the actual README.md content."
        "Do not include markdown code fences (```) for markdown itself, only code inside the content.\n\n"
        f"{complete_module_content}"
    )
    readme_content = query_model(default_system_prompt, readme_prompt)

    # Write the parsed content to respective files
    with open(os.path.join(output_dir, "main.tf"), 'w') as file:
        file.write(resources_content)

    with open(os.path.join(output_dir, "variables.tf"), 'w') as file:
        file.write(variables_content)

    with open(os.path.join(output_dir, "outputs.tf"), 'w') as file:
        file.write(outputs_content)

    with open(os.path.join(output_dir, "README.md"), 'w') as file:
        file.write(readme_content)

    click.echo(f"Terraform module generated and saved to {output_dir}")


if __name__ == '__main__':
    generate_module()
