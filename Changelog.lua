local AddonName, Data = ...

Data.changelog = {
	{
		Version = "10.0.2.7",
		Sections = {
			{
				Header = "Changes",
				Entries = {
					"Reduce the amount of creature types in the settings."
				}
			},
		}
	},
	{
		Version = "10.0.2.6",
		Sections = {
			{
				Header = "Changes",
				Entries = {
					"Added all available creature types to the options."
				}
			},
			{
				Header = "Bugfixes",
				Entries = {
					"Fixed an error reported by Luunii_@curseforge."
				}
			}
		}
	},
	{
		Version = "10.0.2.5",
		Sections = {
			{
				Header = "New Feature",
				Entries = {
					"Completely changed the filtering based on unit type. Removed the filter by players, pets, etc. You can now filter by Creature type (Beast, Demon, Totem, Humanoid, etc). This makes the addon much more useful for rogues. Thanks to largedeltman@curseforge for the hint."
				}
			}
		}
	},
	{
		Version = "10.0.2.4",
		Sections = {
			{
				Header = "New Feature",
				Entries = {
					"Added an option to show/hide the icons on totems. This works based on a small database inside the Addon. If you are missing a totem please let me know."
				}
			},
			{
				Header = "Bugfixes",
				Entries = {
					"Fixed a bug regarding a non existing GUID reported by Luunii_@curseforge."
				}
			}
		}
	},
	{
		Version = "10.0.2.3",
		Sections = {
			{
				Header = "Bugfixes",
				Entries = {
					"Fixed a bug reported by Luunii_@curseforge."
				}
			}
		}
	},
	{
		Version = "10.0.2.2",
		Sections = {
			{
				Header = "Changes",
				Entries = {
					"Improved the default icon positions for new unitframes in Dragonflight.",
					"Added settings to hide or show icons based on unit type (Pet, Player or Creature)."
				}
			}
		}
	},
	{
		Version = "10.0.2.1",
		Sections = {
			{
				Header = "Changes",
				Entries = {
					"Update LibSpellIconSelector library to avoid taint. Thanks to zaphon at GitHub for the report.",
				}
			}
		}
	},
	{
		Version = "10.0.2.0",
		Sections = {
			{
				Header = "Changes",
				Entries = {
					"Toc bump for 10.0.2",
					"Frame for icon selector is now on top/"
				}
			}
		}
	},
	{
		Version = "10.0.0.0",
		Sections = {
			{
				Header = "Updates",
				Entries = {
					"More CPU efficient icon updates",
					"Added a nice new icon selector which is based on the new macro icon selector in Dragonflight 10.0.0"
				}
			}
		}
	},
	{
		Version = "9.2.7.0",
		Sections = {
			{
				Header = "Updates",
				Entries = {
					"Updated TOC"
				}
			},
			{
				Header = "New Feature",
				Entries = {
					"Added an option to disable combat and out of combat icons"
				}
			}
		}
	},
	{
		Version = "9.2.5.0",
		Sections = {
			{
				Header = "Updates",
				Entries = {
					"Updated TOC"
				}
			}
		}
	},
	{
		Version = "9.2.0.2",
		Sections = {
			{
				Header = "Bugfixes",
				Entries = {
					"Removed an unwanted global variable and fixed a error that sometimes appears."
				}
			}
		}
	},
	{
		Version = "9.2.0.1",
		Sections = {
			{
				Header = "Bugfixes",
				Entries = {
					"Fixed a small typo that affected mostly the icon for the player frame not showing up."
				}
			}
		}
	},
	{
		Version = "9.2.0.0",
		Sections = {
			{
				Header = "Completely Rewrite of the addon:",
				Entries = {
					"During the last days/week i completely rewrote the addon and added an options menu and added some new features. Check out the options panel by typing /UnitInCombat into the chat. Feedback highly appreciated."
				}
			}
		}
	}
}
