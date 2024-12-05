from setuptools import setup

setup(
    name="pr-description",
    version="1.0.0",
    py_modules=["pr_description"],
    entry_points={
        "console_scripts": [
            "pr_description=pr_description:main",
        ],
    },
    install_requires=[
        "openai",
        "termcolor",
    ],
)
