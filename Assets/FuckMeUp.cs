using System.Collections;
using System.Collections.Generic;
using SCPE;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

public class FuckMeUp : MonoBehaviour {
    public PostProcessVolume volume;
    private SCPE.Kaleidoscope split;
    public int splits;

    public bool randomizeSplits;

    // Start is called before the first frame update
    void Start() {
        volume.profile.TryGetSettings(out split);
        // StartCoroutine(decreaseSplits());

    }

    // Update is called once per frame
    void Update() {
        split.splits.value = splits;
    }


    public void SetFuckUp(bool v)
    {           

        splits = v?Random.Range(1, 10):0;
        randomizeSplits = v;
        if(v)
            StartCoroutine(fuckMyShitUp());
        else
        {
            StopCoroutine("fuckMyShitUp");
        }
    }

    IEnumerator fuckMyShitUp() {
        while (randomizeSplits) {
            yield return new WaitForSeconds(Random.Range(0.1f, 5));
            if(randomizeSplits)
                splits = Random.Range(1, 10);
        }
    }

    IEnumerator decreaseSplits() {
        while (true) {
            if(!randomizeSplits && splits > 0)
            {
                yield return new WaitForSeconds(Random.Range(3, 13));
                splits = Mathf.Max(0, splits - 1);
            }
            yield return null;
        }
    }
}