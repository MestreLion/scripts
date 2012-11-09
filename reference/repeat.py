from threading import Timer

class RepeatedTimer(object):
    def __init__(self, interval, function, *args, **kwargs):
        self.function = function
        self.interval = interval
        self._timer = None
        self.args = args
        self.kwargs = kwargs
        self.is_running = False
        self.start()

    def _run(self):
        self.is_running = False
        self.start()
        self.function(*self.args, **self.kwargs)

    def start(self):
        if not self.is_running:
            self._timer = Timer(self.interval, self._run)
            self._timer.start()
            self.is_running = True

    def stop(self):
        self._timer.cancel()
        self.is_running = False

def hello(name):
    print "Hello %s!" % name

from time import sleep

print "starting..."
rt = RepeatedTimer(1, hello, "World")

try:
    sleep(5)

    rt.interval = 0.2
    rt.args = ['MestreLion']
    sleep(1)

    rt.stop()
    sleep(3)

    rt.start()
    sleep(1)
finally:
    rt.stop()
