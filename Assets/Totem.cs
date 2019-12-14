using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

[ExecuteInEditMode]
public class Totem : MonoBehaviour
{
    WallPiece[] pieces;
    public int id;
    public int totalWeight;
    public int life;
    private void Awake() 
    {
        pieces = GetComponentsInChildren<WallPiece>();
        foreach(var p in pieces)
        {
            totalWeight += p.weight;
        }
    }
    public void TakeDamage()
    {
        life--;
        if(life <= 0)
        {
            TotemNarration.singlewhat.PlayTotem(id);
            foreach(var p in pieces)
            {
                p.TakeDamage();
            }
        }
    }
}
