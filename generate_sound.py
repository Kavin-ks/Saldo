import math
import struct
import wave
import os
import random

# Configuration
SAMPLE_RATE = 48000
OUTPUT_FILE = "assets/sounds/payment_success.wav"

def generate_wave(frequency, duration, volume=1.0, type='sine'):
    """Generates a raw waveform."""
    n_samples = int(SAMPLE_RATE * duration)
    audio = []
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        val = 0.0
        if type == 'sine':
            val = math.sin(2 * math.pi * frequency * t)
        elif type == 'triangle':
            # Approximation
            val = 2 * abs(2 * (frequency * t - math.floor(frequency * t + 0.5))) - 1
            
        audio.append(val * volume)
    return audio

def apply_envelope(audio, attack=0.01, decay=0.2):
    """Applies a simple percussive envelope."""
    n_samples = len(audio)
    attack_samples = int(SAMPLE_RATE * attack)
    decay_samples = int(SAMPLE_RATE * decay)
    
    processed = []
    for i, sample in enumerate(audio):
        env = 0.0
        if i < attack_samples:
            env = i / attack_samples
        else:
            # Exponential decay
            time_since_peak = (i - attack_samples) / SAMPLE_RATE
            env = math.exp(-8.0 * time_since_peak) # fast sharp decay
            
        processed.append(sample * env)
    return processed

def mix_tracks(tracks, total_duration):
    """Mixes multiple audio tracks."""
    n_total = int(SAMPLE_RATE * total_duration)
    mixed = [0.0] * n_total
    
    for track, start_time in tracks:
        start_idx = int(start_time * SAMPLE_RATE)
        for i, sample in enumerate(track):
            if start_idx + i < n_total:
                mixed[start_idx + i] += sample
                
    return mixed

def add_reverb(audio, delay=0.05, decay=0.5):
    """Adds a simple echo/reverb."""
    delay_samples = int(SAMPLE_RATE * delay)
    out = audio[:]
    for i in range(len(audio)):
        if i >= delay_samples:
            out[i] += out[i - delay_samples] * decay
    return out

def main():
    print(f"Synthesizing High-Density GPay sound to {OUTPUT_FILE}...")
    
    # "Dense" Sound Recipe:
    # 1. Layered frequencies (Unison) for thickness
    # 2. Mix of Sine (purity) and Triangle (body)
    # 3. Reverb tail
    
    # Exact Chime Notes (C6 Major Triad)
    freqs = [1046.50, 1318.51, 1567.98] # C6, E6, G6
    start_times = [0.00, 0.07, 0.14] # Sequential tight timing
    
    tracks = []
    
    for i, freq in enumerate(freqs):
        # MAIN OSCILLATOR (Sine)
        wave_main = generate_wave(freq, 0.6, 0.5, 'sine')
        tracks.append((apply_envelope(wave_main), start_times[i]))
        
        # BODY OSCILLATOR (Triangle, lower vol)
        wave_body = generate_wave(freq, 0.6, 0.2, 'triangle')
        tracks.append((apply_envelope(wave_body), start_times[i]))
        
        # DETUNED LAYERS (for "DENSITY")
        # +3 cents
        wave_high = generate_wave(freq * 1.002, 0.6, 0.15, 'sine')
        tracks.append((apply_envelope(wave_high), start_times[i]))
        
        # -3 cents
        wave_low = generate_wave(freq * 0.998, 0.6, 0.15, 'sine')
        tracks.append((apply_envelope(wave_low), start_times[i]))

    # Mix
    final_mix = mix_tracks(tracks, 1.2)
    
    # Add Reverb/Delay for that "Space" feel
    final_mix = add_reverb(final_mix, delay=0.04, decay=0.2)
    
    # Normalize
    max_val = max(abs(x) for x in final_mix)
    if max_val > 0:
        final_mix = [x / max_val * 0.95 for x in final_mix]
        
    # Save
    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
    with wave.open(OUTPUT_FILE, 'w') as wav_file:
        wav_file.setparams((2, 2, SAMPLE_RATE, len(final_mix), 'NONE', 'not compressed'))
        for sample in final_mix:
            sample = max(-1.0, min(1.0, sample))
            packed = struct.pack('h', int(sample * 32767.0))
            wav_file.writeframes(packed) 
            wav_file.writeframes(packed)
            
    print("Done.")

if __name__ == "__main__":
    main()
