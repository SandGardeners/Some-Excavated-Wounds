using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

using TMPro;
public class WeightDoor : MonoBehaviour
{
    public TMP_Text text;
    public Transform door;
    public int min;
    AudioSource source;
    private void Awake() {
        source = GetComponent<AudioSource>();
    }
    // Start is called before the first frame update
    private void OnTriggerEnter(Collider other) 
    {
        var wd = other.GetComponent<WallDestroyer>();
        
        if(wd != null)
        {
            text.text = string.Format("{0:#,0.000}",wd.CurrentWeight.ToString());
            if(wd.CurrentWeight >= min)
            {
                door.DOLocalMoveY(-5f,3f);
                if(!source.isPlaying)
                    source.Play();
            }
        }
    }

    private void OnTriggerExit(Collider other) {
        text.text = "000";
        door.DOLocalMoveY(2.5f,3f);
        if(!source.isPlaying)
            source.Play();
    }
}
