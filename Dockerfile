#
#
#
#   This Dockerfile is mainly meant for developing and testing:
#     1. docker build --tag appmode ./
#     2. docker run --init -ti -p127.0.0.1:8888:8888 appmode
#     3. open http://localhost:8888/apps/example_app.ipynb
#
#
#
FROM ubuntu:rolling
USER root

# Install some Debian package
RUN export DEBIAN_FRONTEND="noninteractive" \
  && apt-get update && apt-get install -y --no-install-recommends \
    python3-setuptools     \
    python3-wheel          \
    python3-pip            \
    less                  \
    nano                  \
    sudo                  \
    git                   \
    npm                   \
  && rm -rf /var/lib/apt/lists/*

# install Jupyter from git
# WORKDIR /opt/notebook/
# RUN git clone https://github.com/jupyter/notebook.git . && pip3 install .

# install Jupyter via pip
RUN pip3 install notebook

# install ipywidgets
RUN pip3 install ipywidgets  && \
    jupyter nbextension enable --sys-prefix --py widgetsnbextension

# install Appmode
COPY . /opt/appmode
WORKDIR /opt/appmode/
RUN pip3 install .                                           && \
    jupyter nbextension     enable --py --sys-prefix appmode && \
    jupyter serverextension enable --py --sys-prefix appmode

# Possible Customizations
# RUN mkdir -p ~/.jupyter/custom/                                          && \
#     echo "\$('#appmode-leave').hide();" >> ~/.jupyter/custom/custom.js   && \
#     echo "\$('#appmode-busy').hide();"  >> ~/.jupyter/custom/custom.js   && \
#     echo "\$('#appmode-loader').append('<h2>Loading...</h2>');" >> ~/.jupyter/custom/custom.js

# Launch Notebook server
EXPOSE 8888

FROM slicer/slicer-notebook:latest

COPY --chown=sliceruser . ${HOME}/nb
WORKDIR ${HOME}/nb

################################################################################
# launch jupyter
ENTRYPOINT ["/home/sliceruser/run.sh"]
# NOTE: this is only the *default* command. In mybinder, ENTRYPOINT will be
#       called with a custom version of this to set port, token etc.
#       * --ip='' is to avoid bind erorrs inside container
#CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser"]
#CMD ["sh", "-c", "./Slicer/bin/PythonSlicer -m jupyter notebook --port=$JUPYTERPORT --ip=0.0.0.0 --no-browser"]
CMD ["jupyter-notebook", "--ip=0.0.0.0", "--allow-root", "--no-browser", "--NotebookApp.token=''"]


#CMD ["jupyter-notebook", "--ip=0.0.0.0", "--allow-root", "--no-browser", "--NotebookApp.token=''"]
