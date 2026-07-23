package terraform.libraries.makefile

import future.keywords.contains
import future.keywords.if
import future.keywords.in

# 🔴 Violation if Makefile is missing
violation[result] if {
	module_path := input.module_path
	not file_exists(module_path, "Makefile")

	result := {
		"policy": "terraform_module_makefile_policy",
		"severity": "error",
		"message": "Makefile is missing from the module",
		"details": sprintf("Module '%s' does not contain a Makefile", [module_path]),
		"resolution": "Add a Makefile to your module that matches the skeleton",
	}
}

# 🔴 Violation if Makefile exists but doesn't match skeleton
violation[result] if {
	module_path := input.module_path
	file_exists(module_path, "Makefile")

	module_makefile := input.files[sprintf("%s/Makefile", [module_path])]
	skeleton_makefile := input.files["skeletons/generic-skeleton/Makefile"]

	module_makefile != skeleton_makefile

	result := {
		"policy": "terraform_module_makefile_policy",
		"severity": "error",
		"message": "Makefile does not match the skeleton Makefile",
		"details": sprintf("Module '%s' contains a Makefile that does not match the skeleton", [module_path]),
		"resolution": "Copy the Makefile from skeletons/generic-skeleton/Makefile",
	}
}

# 🔴 Violation if .mpm is missing
violation[result] if {
	module_path := input.module_path
	not file_exists(module_path, ".mpm")

	result := {
		"policy": "terraform_module_makefile_policy",
		"severity": "error",
		"message": ".mpm is missing from the module",
		"details": sprintf("Module '%s' does not contain a .mpm", [module_path]),
		"resolution": "Add a .mpm to your module that matches the skeleton",
	}
}

# 🔴 Violation if .mpm exists but doesn't match skeleton
violation[result] if {
	module_path := input.module_path
	file_exists(module_path, ".mpm")

	module_mpm := input.files[sprintf("%s/.mpm", [module_path])]
	skeleton_mpm := input.files["skeletons/generic-skeleton/.mpm"]

	module_mpm != skeleton_mpm

	result := {
		"policy": "terraform_module_makefile_policy",
		"severity": "error",
		"message": ".mpm does not match the skeleton .mpm",
		"details": sprintf("Module '%s' contains a .mpm that does not match the skeleton", [module_path]),
		"resolution": "Copy the .mpm from skeletons/generic-skeleton/.mpm",
	}
}

# ✅ Helper: Checks if a file exists in the input
file_exists(module_path, file) if {
	input.files[sprintf("%s/%s", [module_path, file])]
}
