# Portable JULES (WIP)

The [Joint UK Land Environment Simulator](https://jules.jchmr.org/) is a [land surface model](https://en.wikipedia.org/wiki/Land_surface_models_(climate)) that has been developed over the last 20 years by a wide community of UK researchers coordinated by the [Met Office](https://www.metoffice.gov.uk/) and the [Centre for Ecology Hydrology](https://www.ceh.ac.uk/).

This repository currently serves to document progress towards the development of some minimal, pedagogical examples of JULES simulations that can be run on a typical desktop computer running a Unix-based OS.


## Tutorials and a health warning

For work-in-progress proto-tutorials, see [the Wiki](https://github.com/jmarshrossney/portable-jules/wiki) for this project.

**Health warning:** These tutorials are essentially documentation of my own efforts to run JULES on my personal computer. _I have zero prior familiarity with JULES_, and my FORTRAN knowledge is based on a 6 week internship I did back in 2016.


## What's the point?

The majority of the available documentation for JULES assumes that the user intends to run the model on one of a small number of supported HPC systems - usually [JASMIN](https://jasmin.ac.uk/) (NERC) or [Cray](https://www.metoffice.gov.uk/about-us/who-we-are/innovation/supercomputer) (Met Office) - using a particular suite of configuration and workflow management tools developed by the Met Office.
The fact that this assumption reflects the needs of the majority of users is clearly self-perpetuating, and there seems to be a growing appreciation that this accessibility barrier is a problem.

JULES is ultimately 'just' a FORTRAN-90 model, and it ought to be straightforward to build and run a simple simulation on a standard desktop running a Unix-based OS.
In fact the [technical documentation](https://jules-lsm.github.io/latest/index.html) can get you most of the way there, provided you're prepared for a bit of trial-and-error.

Of course, the scientific value of these simulations will be minimal, but that is not the point.
The point is to strip away the abstractions and play around with the base model - to have fun and learn!


## Broader aims

There are some additional aims I would like to work towards.

- The configuration via FORTRAN namelists is very brittle. Consider approaches for improving reproducibility, including dependency, configuration and data management & version control

- Consider a containerised approach that reduces discontinuity when scaling up to HPC systems.

- Making it easy to programmatically modify parameters and input data for e.g. sensitivity analyses, generating training data for statistical models etc.


## Notes

Work done while at UKCEH - repository will be transferred to [NERC-CEH](https://github.com/NERC-CEH) if/when it becomes useful.
