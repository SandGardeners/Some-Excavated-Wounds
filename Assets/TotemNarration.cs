using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

public class TotemNarration : MonoBehaviour
{
    public static TotemNarration singlewhat;
   public AudioClip[] clips;
   public string[] subtitles;

   public FirstPersonAIO player;
   public FuckMeUp fuckMe;
    AudioSource source;
    public AudioMixer mixer;
    public AudioMixerSnapshot[] snapshots;
    public float[] playingVoiceWeights;
    public float[] regularWeights;

    public Transform narrationUI;
    public GameObject gameUI;
    private void Awake() {
        singlewhat = this;
        source = GetComponent<AudioSource>();
    }

    int curID;
    public void PlayTotem(int id)
    {
        curID = id;
        source.PlayOneShot(clips[id]);
        mixer.TransitionToSnapshots(snapshots, playingVoiceWeights,1f);
        Invoke("DonePlaying",clips[id].length);
        fuckMe.SetFuckUp(true);
        player.playerCanMove = false;
        gameUI.SetActive(false);
        narrationUI.GetChild(id).gameObject.SetActive(true);
    }

    public void DonePlaying()
    {
        if(curID != 6)
            player.playerCanMove = true;
        else
            Invoke("Quit",60f);
        fuckMe.SetFuckUp(false);
        narrationUI.GetChild(curID).gameObject.SetActive(false);
        mixer.TransitionToSnapshots(snapshots, regularWeights,1f);
        gameUI.SetActive(true);
    }

    public void Quit()
    {
        Application.Quit();
    }
}
