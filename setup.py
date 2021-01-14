# Install PyTorch extensions and projector
# pip install .

from setuptools import setup
from torch.utils import cpp_extension

setup(
    name='stylegan2-pytorch',
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
    py_modules=[
        'model',
        'projector',
    ],
    packages=[
        'lpips',
        'op',
    ],
    zip_safe=False,
    include_package_data=True,
    author='Stefan H. Holek',
    author_email='stefan@naturalvision.de',
    url='https://github.com/naturalvision/stylegan2-pytorch',
)
