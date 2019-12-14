using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public class ItemsTracker : MonoBehaviour
{
    public List<WallPiece> toTrack;
    List<TMPro.TMP_Text> textTrackers;
    public GameObject prefab;
    public float minDist;

    public static ItemsTracker tracker;
    private void Awake() {
        tracker = this;
        textTrackers = new List<TMPro.TMP_Text>();
    }

    public void AddRenderer(WallPiece r)
    {
        toTrack.Add(r);
    }

    public void RemoveRenderer(WallPiece r)
    {
        toTrack.Remove(r);
    }
    
    void Update()
    {
    for(int i = 0; i < transform.childCount; i++)
    {
        if(i >= toTrack.Count)
        {
            transform.GetChild(i).gameObject.SetActive(false);
        }
    }
        for(int i = 0; i < toTrack.Count; i++)
        {
            if(i >= transform.childCount)
            {
                textTrackers.Add(Instantiate(prefab, transform).GetComponentInChildren<TMPro.TMP_Text>());
            }


            Vector3 pos = Camera.main.WorldToScreenPoint(toTrack[i].renderer.bounds.center);
            float dist = Vector3.Distance(toTrack[i].transform.position, Camera.main.transform.position); 
            if(dist > minDist || pos.x > Screen.width || pos.x < 0f || pos.y > Screen.height || pos.y < 0f || pos.z <= 0f)
            {
                (transform.GetChild(i).gameObject).SetActive(false);
                // textTrackers.RemoveAt(i);
            }
            else
            {
                (transform.GetChild(i).gameObject).SetActive(true);
                transform.GetChild(i).GetComponent<RectTransform>().position = pos;
                textTrackers[i].text = new StringBuilder(toTrack[i].weight.ToString()).Append("$").ToString(); 
            }

        }    
    }
}
