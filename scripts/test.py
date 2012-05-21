# Trying some crazy "class property" wizardry

class MyClass(object):
	"""class doc"""

	cls_attr = "cls attr value"

	@classmethod
	def cls_method(cls):
		"""cls method doc"""
		return "cls method value"

	@property
	@classmethod
	def crazy(cls):
		"""crazy doc"""
		return "crazy value"

	def __init__(self):
		"""init doc"""
		self.attr = "attr value"

	def method(self):
		"""method doc"""
		return "method value"

	@property
	def prop(self):
		"""prop doc"""
		return "prop value"


print "Class values:"
print MyClass.cls_attr
print MyClass.cls_method()

obj = MyClass()

print
print "Instance values:"
print obj.attr
print obj.method()
print obj.prop

print
print "Class docs:"
print "MyClass.__doc__ = ", MyClass.__doc__
print "MyClass.cls_method.__doc__ = ", MyClass.cls_method.__doc__
print "MyClass.__init__.__doc__ = ", MyClass.__init__.__doc__
print "MyClass.method.__doc__ = ", MyClass.method.__doc__
print "MyClass.prop.__doc__ = ", MyClass.prop.__doc__

print
print "Instance docs - same as class ones for all but the property"
print "obj.__doc__ = ", obj.__doc__
print "obj.__init__.__doc__ = ", obj.__init__.__doc__
print "obj.method.__doc__ = ", obj.method.__doc__
print "obj.prop.__doc__ = ", obj.prop.__doc__

print
print "Crazy test:"
print MyClass.crazy
print "MyClass.crazy.__doc__ = ", MyClass.crazy.__doc__

# And the results are...
