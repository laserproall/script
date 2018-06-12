# -*- coding: utf-8 -*-
class Chain(object):

    def __init__(self, path=''):
        self._path = path

    def __getattr__(self, path):
        return Chain('%s/%s' % (self._path, path))

    def __call__(self,name):
        return Chain('%s/%s' % (self._path, name))

    def __str__(self):
        return self._path

    __repr__ = __str__