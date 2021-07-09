# We use the iqsharp-base image, as that includes
# the .NET Core SDK, IQ#, and Jupyter Notebook already
# installed for us.
FROM mcr.microsoft.com/quantum/iqsharp-base:0.18.210729079-pull

# Add metadata indicating that this image is used for the katas.
ENV IQSHARP_HOSTING_ENV=KATAS_DOCKERFILE

# Make sure the contents of our repo are in ${HOME}
# Required for mybinder.org
COPY . ${HOME}

# Run some commands as root
USER root
# Install Python dependencies for the Python visualization and tutorial notebooks
RUN pip install -I --no-cache-dir \
        matplotlib \
        numpy \
        pytest && \
# Give permissions to the jovyan user
    chown -R ${USER} ${HOME} && \
    chmod +x ${HOME}/scripts/*.sh

# From now on, just run things as the jovyan user
USER ${USER}

RUN cd ${HOME} && \
# `dotnet restore` for each solution to ensure NuGet cache is fully populated
    for solution in $(find . -type f -name "*.sln"); do dotnet restore "$solution"; done && \
# Pre-exec notebooks to improve first-use start time
# (the katas that are less frequently used on Binder are excluded to improve overall Binder build time)
    ./scripts/prebuild-kata.sh BasicGates && \
    ./scripts/prebuild-kata.sh CHSHGame && \
    ./scripts/prebuild-kata.sh DeutschJozsaAlgorithm && \
    ./scripts/prebuild-kata.sh DistinguishUnitaries && \
    #./scripts/prebuild-kata.sh GHZGame && \
    ./scripts/prebuild-kata.sh GraphColoring && \
    ./scripts/prebuild-kata.sh GroversAlgorithm && \
    ./scripts/prebuild-kata.sh JointMeasurements && \
    #./scripts/prebuild-kata.sh KeyDistribution_BB84 && \
    #./scripts/prebuild-kata.sh MagicSquareGame && \
    ./scripts/prebuild-kata.sh Measurements && \
    ./scripts/prebuild-kata.sh PhaseEstimation && \
    #./scripts/prebuild-kata.sh QEC_BitFlipCode && \
    ./scripts/prebuild-kata.sh QFT && \
    #./scripts/prebuild-kata.sh RippleCarryAdder && \
    ./scripts/prebuild-kata.sh SolveSATWithGrover && \
    ./scripts/prebuild-kata.sh SuperdenseCoding && \
    ./scripts/prebuild-kata.sh Superposition && \
    ./scripts/prebuild-kata.sh Teleportation && \
    ./scripts/prebuild-kata.sh TruthTables && \
    # Exclude Unitary patterns, since it times out in Binder prebuild
    #./scripts/prebuild-kata.sh UnitaryPatterns && \
    ./scripts/prebuild-kata.sh tutorials/ComplexArithmetic ComplexArithmetic.ipynb && \
    ./scripts/prebuild-kata.sh tutorials/ExploringDeutschJozsaAlgorithm DeutschJozsaAlgorithmTutorial.ipynb && \
    ./scripts/prebuild-kata.sh tutorials/ExploringGroversAlgorithm ExploringGroversAlgorithmTutorial.ipynb && \
    ./scripts/prebuild-kata.sh tutorials/LinearAlgebra LinearAlgebra.ipynb && \
    ./scripts/prebuild-kata.sh tutorials/MultiQubitGates MultiQubitGates.ipynb && \
    ./scripts/prebuild-kata.sh tutorials/MultiQubitSystems MultiQubitSystems.ipynb && \
    ./scripts/prebuild-kata.sh tutorials/Oracles Oracles.ipynb && \
    ./scripts/prebuild-kata.sh tutorials/Qubit Qubit.ipynb && \
    ./scripts/prebuild-kata.sh tutorials/RandomNumberGeneration RandomNumberGenerationTutorial.ipynb && \
    ./scripts/prebuild-kata.sh tutorials/SingleQubitGates SingleQubitGates.ipynb && \
    ./scripts/prebuild-kata.sh tutorials/SingleQubitSystemMeasurements SingleQubitSystemMeasurements.ipynb && \
    # Exclude VisualizationTools, as %debug cell times out in Binder prebuild
    #./scripts/prebuild-kata.sh tutorials/VisualizationTools VisualizationTools.ipynb && \
# To improve performance when loading packages at IQ# kernel initialization time,
# we remove all online sources for NuGet such that IQ# Package Loading and NuGet dependency
# resolution won't attempt to resolve package dependencies again (as it was already done
# during the prebuild steps above).
# The downside is that only packages that were already downloaded to .nuget/packages folder
# will be available to get loaded.
# Users that require loading additional packages should use the iqsharp-base image instead.
    rm ${HOME}/NuGet.config && \
    echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>\
          <configuration>\
              <packageSources>\
                   <clear />\
              </packageSources>\
          </configuration>\
    " > ${HOME}/.nuget/NuGet/NuGet.Config

# Set the working directory to $HOME (/home/jovyan/)
WORKDIR ${HOME}

# Set default command when running a Docker container instance
CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0"]
