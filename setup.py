# Install PyTorch extensions
# pip install .

from setuptools import setup
from torch.utils import cpp_extension

setup(
    name='stylegan2-pytorch-ops',
    version='1.0.0',
    ext_modules=[
        cpp_extension.CppExtension(
            'fused', ['op/fused_bias_act.cpp', 'op/fused_bias_act_kernel.cu']),
        cpp_extension.CppExtension(
            'upfirdn2d', ['op/upfirdn2d.cpp', 'op/upfirdn2d_kernel.cu']),
    ],
    cmdclass={
        'build_ext': cpp_extension.BuildExtension,
    },
)
