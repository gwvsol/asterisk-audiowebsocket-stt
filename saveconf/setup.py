import os
from importlib.machinery import SourceFileLoader

from pkg_resources import parse_requirements
from setuptools import find_packages, setup

module_name = 'saveconf'

module = SourceFileLoader(
    module_name, os.path.join(module_name, '__init__.py')
).load_module()


def load_requirements(fname: str) -> list:
    requirements = []
    with open(fname, 'r') as fp:
        for req in parse_requirements(fp.read()):
            requirements.append('{}{}'.format(req.name, req.specifier))
    return requirements


setup(
    name=module_name,
    version=module.__version__,
    author=module.__author__,
    author_email=module.__email__,
    license=module.__license__,
    description=module.__doc__,
    long_description=__doc__,
    platforms='all',
    classifiers=[
        'Intended Audience :: Developers',
        'Natural Language :: Russian',
        'Operating System :: POSIX',
        'Programming Language :: Python',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.8'
    ],
    python_requires='>=3.8',
    packages=find_packages(),
    # install_requires=load_requirements('requirements.txt'),
    include_package_data=True,
    entry_points={
        'console_scripts': [
            '{0} = {0}.__main__:main'.format(module_name)
        ]
    }
)
