import setuptools
import tokenize

# This is a setuptools shim so that setuptools is imported before distutils.
# Based on pip's: https://github.com/pypa/pip/pull/3265
# https://github.com/pypa/pip/blob/master/pip/utils/setuptools_build.py

__file__='setup.py'

f=getattr(tokenize, 'open', open)(__file__)
code=f.read().replace('\\r\\n', '\\n')
f.close()

exec(compile(code, __file__, 'exec'))
