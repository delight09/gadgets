#!/bin/env bash
# remove sound related kernel module to save battery juice

sudo rmmod snd_hda_intel snd_hwdep snd_hda_codec snd_timer snd_hda_codec_hdmi snd_hda_codec_generic snd_hda_codec_realtek snd_pcm snd_hda_codec snd_hda_codec_hdmi snd_hda_codec_generic snd_hda_codec_realtek snd_pcm  snd_hda_codec snd_hda_core
soundcore snd
