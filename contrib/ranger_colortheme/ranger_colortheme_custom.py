__copyright__ = "Copyright (C) 2018 Xiaoyu Wei"

__license__ = """
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
"""

from ranger.gui.colorscheme import ColorScheme
from ranger.gui.color import *


class SolarizedColors(object):
    base03 = 234
    base02 = 235
    base01 = 240
    base00 = 241
    base0 = 244
    base1 = 245
    base2 = 254
    base3 = 230
    yellow = 136
    orange = 166
    red = 160
    magenta = 125
    violet = 61
    blue = 33
    cyan = 37
    green = 64


class CustomColors(object):
    def __init__(self, light=True):
        if light:
            self.background = SolarizedColors.base3
            self.background_highlights = SolarizedColors.base2
            self.secondary_content = SolarizedColors.base1
            self.primary_content = SolarizedColors.base00
            self.emphasized_content = SolarizedColors.base01
        else:
            self.background = SolarizedColors.base03
            self.background_highlights = SolarizedColors.base02
            self.secondary_content = SolarizedColors.base01
            self.primary_content = SolarizedColors.base0
            self.emphasized_content = SolarizedColors.base1

# TODO: time-dependent colorscheme
IS_DAYTIME = True
CCS = CustomColors(light=IS_DAYTIME)

class Custom(ColorScheme):

    def use(self, context):
        fg = CCS.primary_content

        # Use terminal bg, better when truecolor is used outside ranger
        # bg = CCS.background
        bg = -1

        # No special effects by default
        attr = 0

        if context.reset:
            return default_colors

        elif context.in_browser:
            if context.selected:
                attr = reverse
            else:
                attr = normal
            if context.empty or context.error:
                fg = SolarizedColors.red
            if context.border:
                fg = CCS.secondary_content
            if context.image:
                fg = SolarizedColors.violet
            if context.video:
                fg = SolarizedColors.violet
            if context.audio:
                fg = SolarizedColors.violet
            if context.document:
                fg = CCS.primary_content
            if context.container:
                attr |= bold
                fg = SolarizedColors.cyan
            if context.directory:
                attr |= bold
                fg = SolarizedColors.blue
            elif context.executable and not \
                    any((context.media, context.container,
                       context.fifo, context.socket)):
                attr |= bold
                fg = SolarizedColors.magenta
            if context.socket:
                fg = SolarizedColors.cyan
                attr |= bold
            if context.fifo or context.device:
                fg = SolarizedColors.violet
                if context.device:
                    attr |= bold
            if context.link:
                fg = context.good and CCS.primary_content or SolarizedColors.red
                bg = CCS.background_highlights
            if context.bad:
                bg = SolarizedColors.orange
            if context.tag_marker and not context.selected:
                attr |= bold
                if fg in (SolarizedColors.red, SolarizedColors.magenta):
                    fg = CCS.primary_content
                else:
                    fg = SolarizedColors.red
            if not context.selected and (context.cut or context.copied):
                fg = CCS.secondary_content
                bg = CCS.background_highlights
            if context.main_column:
                if context.selected:
                    attr |= bold
                if context.marked:
                    attr |= bold
                    fg = CCS.emphasized_content
            if context.badinfo:
                if attr & reverse:
                    bg = SolarizedColors.orange
                else:
                    fg = SolarizedColors.orange

        elif context.in_titlebar:
            attr |= bold
            if context.hostname:
                fg = context.bad and SolarizedColors.red or CCS.emphasized_content
            elif context.directory:
                fg = CCS.secondary_content
            elif context.tab:
                if context.good:
                    fg = CCS.primary_content
                    bg = CCS.background_highlights
            elif context.link:
                fg = SolarizedColors.blue

        elif context.in_statusbar:
            if context.permissions:
                if context.good:
                    fg = SolarizedColors.blue
                elif context.bad:
                    fg = SolarizedColors.red
            if context.marked:
                attr |= bold | reverse
                fg = SolarizedColors.yellow
            if context.message:
                if context.bad:
                    attr |= bold
                    fg = SolarizedColors.violet
            if context.loaded:
                bg = SolarizedColors.magenta
            if context.vcsinfo:
                fg = SolarizedColors.cyan
                attr &= ~bold
            if context.vcscommit:
                fg = SolarizedColors.violet
                attr &= ~bold

        if context.text:
            if context.highlight:
                attr |= reverse

        if context.in_taskview:
            if context.title:
                fg = CCS.emphasized_content

            if context.selected:
                attr |= reverse

            if context.loaded:
                if context.selected:
                    fg = SolarizedColors.magenta
                else:
                    bg = SolarizedColors.magenta

        if context.vcsfile and not context.selected:
            attr &= ~bold
            if context.vcsconflict:
                fg = SolarizedColors.orange
            elif context.vcschanged:
                fg = SolarizedColors.cyan
            elif context.vcsunknown:
                fg = SolarizedColors.red
            elif context.vcsstaged:
                fg = SolarizedColors.primary_content
            elif context.vcssync:
                fg = SolarizedColors.green
            elif context.vcsignored:
                fg = SolarizedColors.secondary_content

        elif context.vcsremote and not context.selected:
            attr &= ~bold
            if context.vcssync:
                fg = SolarizedColors.green
            elif context.vcsbehind:
                fg = SolarizedColors.secondary_content
            elif context.vcsahead:
                fg = SolarizedColors.blue
            elif context.vcsdiverged:
                fg = SolarizedColors.orange
            elif context.vcsunknown:
                fg = SolarizedColors.red

        return fg, bg, attr
