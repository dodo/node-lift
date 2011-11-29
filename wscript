from os.path import dirname, join
import os

top = "."
out = "build"

class Dummy: pass


def configure(ctx):
    ctx.env.PATH = os.environ['PATH'].split(os.pathsep)
    ctx.env.PATH.append(join(ctx.cwd, "node_modules", "coffee-script", "bin"))
    ctx.find_program("coffee", var="COFFEE", path_list=ctx.env.PATH)
    ctx.env.ARGS = "-co"
    ctx.env.set_variant("default")


def build(ctx):
    env = Dummy()
    env.variant = lambda: ""
    for file in ctx.path.find_dir("src").ant_glob("**/*.coffee", flat=False):
        tgtpath = file.change_ext(".js").bldpath(env)[5:]
        ctx.path.exclusive_build_node(tgtpath)
        ctx(name   = "coffee",
            rule   = "${COFFEE} ${ARGS} default/%s ${SRC}" % dirname(tgtpath),
            source = file.srcpath()[3:],
            target = tgtpath)
