# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025-2026, by Samuel Williams.

# Update copyrights and project documentation for the new version.
#
# @parameter version [String] The new version number.
def after_gem_release_version_increment(version)
	context["modernize:license"].call
	context["releases:update"].call(version)
	context["utopia:project:update"].call
end
