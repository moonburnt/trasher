Because sometimes you need smol bash script to trash useless files from command line... *only to realise later that gio already provide such functionality*...

**Dependencies**:
- coreutils
- bash
- sed
- jq (for urlencoding. And no, self-written sed rules arent enough for that purpose, since they wont deal with non-latin symbols)

**Limitations**:
- Its **not a complete trash management solution**. The only thing, this script does - is, well, send files to trash bin with matching .trashinfo data for further restoration.
- For now, expected trash bin's location is **limited to $HOME/.local/share/Trash**, meaning that if you are trying to trash files from different partitions - they will be moved to partition with $HOME on it. I will try to do something about that later. Maybe.
