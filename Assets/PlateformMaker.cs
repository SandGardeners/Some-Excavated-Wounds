using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
public class PlateformMaker : MonoBehaviour
{
    private void Awake() {
        SkinnedMeshRenderer mr = GetComponent<SkinnedMeshRenderer>();
        DOTween.To(()=>mr.GetBlendShapeWeight(0),(x)=>mr.SetBlendShapeWeight(0,x), 0, 0.25f); 
        // mr.SetBlendShapeWeight(0,100);
    }
}
